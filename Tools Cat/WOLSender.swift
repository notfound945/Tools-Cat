import Foundation
import Darwin

enum WOLSenderError: Error {
    case invalidMAC
    case socketFailed
    case setsockoptFailed
    case sendFailed
}

struct WOLSender {
    static func send(to macString: String) throws {
        let mac = try parseMAC(from: macString)
        let macPretty = mac.map { String(format: "%02X", $0) }.joined(separator: ":")
        var packet = Data(repeating: 0xFF, count: 6)
        for _ in 0..<16 { packet.append(mac) }
        print("[WOL] Target MAC=\(macPretty), packetBytes=\(packet.count)")

        let sock = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP)
        guard sock >= 0 else {
            let err = String(cString: strerror(errno))
            print("[WOL][Error] socket failed: \(err)")
            throw WOLSenderError.socketFailed
        }
        defer { close(sock) }

        var yes: Int32 = 1
        if setsockopt(sock, SOL_SOCKET, SO_BROADCAST, &yes, socklen_t(MemoryLayout.size(ofValue: yes))) < 0 {
            let err = String(cString: strerror(errno))
            print("[WOL][Error] setsockopt SO_BROADCAST failed: \(err)")
            throw WOLSenderError.setsockoptFailed
        }

        // 收集所有可用 IPv4 广播地址
        let broadcasts = enumerateIPv4Broadcasts()
        let allTargets: [(ifname: String?, ifindex: UInt32?, addr: in_addr)] = broadcasts.isEmpty
            ? [("default-broadcast", nil, in_addr(s_addr: INADDR_BROADCAST.bigEndian))]
            : broadcasts
        print("[WOL] Broadcast targets count=\(allTargets.count)")

        var anySuccess = false
        for (ifnameOpt, ifindexOpt, dest) in allTargets {
            let ip = ipv4ToString(dest)
            if let name = ifnameOpt { print("[WOL] Destination=\(ip):9 via \(name)") } else { print("[WOL] Destination=\(ip):9") }

            var addr = sockaddr_in()
            addr.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
            addr.sin_family = sa_family_t(AF_INET)
            addr.sin_port = in_port_t(9).bigEndian
            addr.sin_addr = dest

            if let ifindex = ifindexOpt {
                var idx = ifindex
                if setsockopt(sock, IPPROTO_IP, IP_BOUND_IF, &idx, socklen_t(MemoryLayout.size(ofValue: idx))) < 0 {
                    let err = String(cString: strerror(errno))
                    if let n = ifnameOpt { print("[WOL][Warn] IP_BOUND_IF(\(n)#\(ifindex)) failed: \(err)") } else { print("[WOL][Warn] IP_BOUND_IF(\(ifindex)) failed: \(err)") }
                } else {
                    if let n = ifnameOpt { print("[WOL] Bound to \(n) (ifindex=\(ifindex))") } else { print("[WOL] Bound to ifindex=\(ifindex)") }
                }
            }

            let sent = packet.withUnsafeBytes { buf -> ssize_t in
                var a = addr
                return withUnsafePointer(to: &a) { ptr in
                    ptr.withMemoryRebound(to: sockaddr.self, capacity: 1) { saPtr in
                        sendto(sock, buf.baseAddress, buf.count, 0, saPtr, socklen_t(MemoryLayout<sockaddr_in>.size))
                    }
                }
            }

            if sent < 0 {
                let err = String(cString: strerror(errno))
                print("[WOL][Error] sendto to \(ip) failed: \(err)")
            } else {
                print("[WOL] Sent bytes=\(sent) to \(ip)")
                anySuccess = true
            }
        }

        if !anySuccess { throw WOLSenderError.sendFailed }
    }

    private static func parseMAC(from input: String) throws -> Data {
        let hex = input.replacingOccurrences(of: "[^0-9A-Fa-f]", with: "", options: .regularExpression)
        guard hex.count == 12 else { throw WOLSenderError.invalidMAC }
        var bytes = Data(capacity: 6)
        var index = hex.startIndex
        for _ in 0..<6 {
            let next = hex.index(index, offsetBy: 2)
            let byteStr = String(hex[index..<next])
            guard let value = UInt8(byteStr, radix: 16) else { throw WOLSenderError.invalidMAC }
            bytes.append(value)
            index = next
        }
        return bytes
    }

    private static func enumerateIPv4Broadcasts() -> [(String, UInt32, in_addr)] {
        var results: [(String, UInt32, in_addr)] = []
        var ifaddrPtr: UnsafeMutablePointer<ifaddrs>? = nil
        guard getifaddrs(&ifaddrPtr) == 0, let first = ifaddrPtr else { return results }
        defer { freeifaddrs(ifaddrPtr) }

        var cursor: UnsafeMutablePointer<ifaddrs>? = first
        while let ifa = cursor?.pointee {
            defer { cursor = ifa.ifa_next }
            let flags = Int32(ifa.ifa_flags)
            // 跳过未启用、回环、点对点（如 VPN）接口
            guard flags & IFF_UP != 0, flags & IFF_LOOPBACK == 0, flags & IFF_POINTOPOINT == 0 else { continue }
            guard let addrPtr = ifa.ifa_addr, addrPtr.pointee.sa_family == UInt8(AF_INET) else { continue }

            // 优先使用接口提供的广播地址
            let ifname = String(cString: ifa.ifa_name)
            if flags & IFF_BROADCAST != 0, let dstPtr = ifa.ifa_dstaddr {
                let sin = UnsafeRawPointer(dstPtr).assumingMemoryBound(to: sockaddr_in.self).pointee
                let ifindex = if_nametoindex(ifa.ifa_name)
                print("[WOL] Found iface \(ifname) (ifindex=\(ifindex)) broadcast=\(ipv4ToString(sin.sin_addr))")
                results.append((ifname, ifindex, sin.sin_addr))
                continue
            }

            // 退化：根据地址与掩码计算广播地址
            guard let maskPtr = ifa.ifa_netmask else { continue }
            let sinAddr = UnsafeRawPointer(addrPtr).assumingMemoryBound(to: sockaddr_in.self).pointee
            let sinMask = UnsafeRawPointer(maskPtr).assumingMemoryBound(to: sockaddr_in.self).pointee
            let addr = UInt32(bigEndian: sinAddr.sin_addr.s_addr)
            let mask = UInt32(bigEndian: sinMask.sin_addr.s_addr)
            let bcastHostOrder = (addr & mask) | (~mask)
            let bcast = in_addr(s_addr: in_addr_t(bcastHostOrder).bigEndian)
            let ifindex = if_nametoindex(ifa.ifa_name)
            // 跳过等于自身 IP 的“伪广播”
            if sinAddr.sin_addr.s_addr != bcast.s_addr {
                print("[WOL] Derived iface \(ifname) (ifindex=\(ifindex)) broadcast=\(ipv4ToString(bcast))")
                results.append((ifname, ifindex, bcast))
            }
        }
        // 去重
        var seen = Set<String>()
        results = results.filter {
            let key = "\($0.0)#\(String($0.2.s_addr))"
            let inserted = !seen.contains(key)
            if inserted { seen.insert(key) }
            return inserted
        }
        return results
    }

    private static func ipv4ToString(_ addr: in_addr) -> String {
        var a = addr
        var buffer = [CChar](repeating: 0, count: Int(INET_ADDRSTRLEN))
        let cStr = inet_ntop(AF_INET, &a, &buffer, socklen_t(INET_ADDRSTRLEN))
        return cStr != nil ? String(cString: buffer) : "<invalid>"
    }
}
