# @version 0.3.7

from vyper.interfaces import ERC20

implements: ERC20

balances: public(HashMap[address, uint256])
allowed: public(HashMap[address, HashMap[address, uint256]])
total_supply: public(uint256)

event Transfer:
    _from: indexed(address)
    _to: indexed(address)
    value: uint256

event Approval:
    _owner: indexed(address)
    _spender: indexed(address)
    value: uint256

@external #@public
def __init__(_initial_supply: uint256):
    self.total_supply = _initial_supply

@internal
def _mint(to: address, value: uint256):
    assert self.total_supply + value > self.total_supply
    assert self.balances[to] + value > self.balances[to]

    self.total_supply += value
    self.balances[to] += value

    log Transfer(empty(address), to, value)

@external
def allowance(_owner: address, _spender: address):
    pass

@external
def approve(_spender: address, value: uint256):
    pass

@external
def balanceOf(_owner: address) -> uint256:
    return self.balances[_owner]

@external
def totalSupply() -> uint256:
    return self.total_supply

@external
def transfer(_to: address, value: uint256) -> bool:
    assert self.balances[msg.sender] >= value
    assert self.balances[_to] + value >= self.balances[_to]

    self.balances[msg.sender] -= value
    self.balances[_to] += value

    log Transfer(msg.sender, _to, value)

    return True

@external
def transferFrom(_from: address, _to: address, value: uint256) -> bool:
    assert self.balances[_from] >= value
    assert self.balances[_to] + value >= self.balances[_to]
    assert self.allowed[_from][msg.sender] >= value

    self.balances[_to] += value
    self.balances[_from] -= value
    self.allowed[_from][msg.sender] -= value

    log Transfer(_from, _to, value)

    return True

@external
@payable
def __default__():
    self._mint(msg.sender, msg.value)