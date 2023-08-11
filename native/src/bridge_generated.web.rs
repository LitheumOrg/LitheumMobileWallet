use super::*;
// Section: wire functions

#[wasm_bindgen]
pub fn wire_greet(port_: MessagePort) {
    wire_greet_impl(port_)
}

#[wasm_bindgen]
pub fn wire_generate_keypair(port_: MessagePort) {
    wire_generate_keypair_impl(port_)
}

#[wasm_bindgen]
pub fn wire_get_address(port_: MessagePort, slice: Box<[u8]>) {
    wire_get_address_impl(port_, slice)
}

#[wasm_bindgen]
pub fn wire_get_balance(port_: MessagePort) {
    wire_get_balance_impl(port_)
}

// Section: allocate functions

// Section: related functions

// Section: impl Wire2Api

impl Wire2Api<Vec<u8>> for Box<[u8]> {
    fn wire2api(self) -> Vec<u8> {
        self.into_vec()
    }
}
// Section: impl Wire2Api for JsValue

impl Wire2Api<u8> for JsValue {
    fn wire2api(self) -> u8 {
        self.unchecked_into_f64() as _
    }
}
impl Wire2Api<Vec<u8>> for JsValue {
    fn wire2api(self) -> Vec<u8> {
        self.unchecked_into::<js_sys::Uint8Array>().to_vec().into()
    }
}
