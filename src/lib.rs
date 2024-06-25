pub mod device;

use std::arch::global_asm;
use std::io::Result;

use crate::device::Device;

global_asm!(include_str!("lib.asm"));

extern {
    fn on_rcvd_frame(frame: *const u8, n: u64);
}

pub fn init(d: impl Device) -> Result<()> {
    let mut buf = [0u8; 1504];
    loop {
        let n = d.recv(&mut buf[..])?;
        eprintln!("{} {:x?}", n, &buf[..n]);

        unsafe { on_rcvd_frame(&buf as *const u8, n as u64); }
    }
}

#[cfg(test)]
mod tests {
    use std::io::Result;

    extern {
        fn on_rcvd_frame(frame: *const u8, n: u64);
    }

    #[test]
    fn ping() -> Result<()> {
        let buf: Vec<u8> = vec![0, 1];
        unsafe { on_rcvd_frame(buf.as_ptr(), buf.len() as u64); }
        Ok(())
    }
}
