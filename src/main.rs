use std::io::Result;
use utcp::device::Device;

struct Tun {
    iface: tun_tap::Iface,
}

impl Device for Tun {
    fn send(&self, buf: &[u8]) -> Result<usize> {
        self.iface.send(buf)
    }

    fn recv(&self, buf: &mut [u8]) -> Result<usize> {
        self.iface.recv(buf)
    }
}

fn main() -> Result<()> {
    let tun = Tun {
        iface: tun_tap::Iface::new("tun0", tun_tap::Mode::Tun)?
    };

    utcp::init(tun)
}
