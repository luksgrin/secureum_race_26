# @version 0.3.7

@external
@pure
def unsafeSum(a: uint256, b: uint256) -> uint256:
    return unsafe_add(a, b)

@external
def weird1(a: uint256, b: uint256) -> uint256:
    return _abi_decode(
        raw_call(
            self,
            _abi_encode(
                (a, b),
                method_id=method_id("unsafeSum(uint256,uint256)")
            ),
            max_outsize=32
        ),
        uint256
    )

@external
def weird2(a: uint256, b: uint256) -> uint256:
    return _abi_decode(
        raw_call(
            self,
            _abi_encode((
                keccak256("unsafeSum(uint256,uint256)"),
                a,
                b
            )),
            max_outsize=32
        ),
        uint256
    )

@external
def weird3(a: uint256, b: uint256) -> uint256:
    return _abi_decode(
        raw_call(
            self,
            _abi_encode((
                0x4f388eb1,
                a,
                b
            )),
            max_outsize=32
        ),
        uint256
    )

@external
def weird4(a: uint256, b: uint256) -> uint256:
    return _abi_decode(
        raw_call(
            self,
            _abi_encode(
                (a, b),
                method_id=0x4f388eb1
            ),
            max_outsize=32
        ),
        uint256
    )