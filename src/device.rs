use std::io::Result;

pub trait Device {
    fn send(&self, buf: &[u8]) -> Result<usize>;
    fn recv(&self, buf: &mut [u8]) -> Result<usize>;
}
