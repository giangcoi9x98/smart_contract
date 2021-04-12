pragma solidity >= 0.7.0 <= 0.8.0;

import './DoMath.sol';
import './Ownable.sol';
contract GCoin {
    using DoMath for uint;

    mapping (address => uint) balances;
    string public symbol = 'GCOIN';
    uint public decimal = 6;
    address public owner;
    address public peerToPeerLendingContractAddress;
    
    constructor() public {
        owner = msg.sender;
    }

    event hasTransfer (address _sender, address _receiver, uint _amount);
    event TokenSold(address _receiver, uint _amount);

    modifier onlyOwner () {
        require(owner == msg.sender,'Only owner can call');
        _;
    }

    modifier onlyPeerToPeerLendingContract () {
        require(
            peerToPeerLendingContractAddress == msg.sender,
             'Only PeerToPeerLendingContract '
            );
        _;
    }

    function setpeerToPeerLendingContractAddress (address _address) public {
        peerToPeerLendingContractAddress = _address;
    }

    function mint (address _receiver, uint _amount) public onlyOwner {
        balances[_receiver] = balances[_receiver].add(_amount);
    }

    function send(address _receiver, uint _amount) public {
        _transfer(msg.sender, _receiver, _amount);
    }

    function getBalance (address _sender) public view returns (uint) {
        return balances[_sender];
    }

    function _transfer (address _sender, address _receiver, uint _amount) private {
        require(balances[_sender] >= _amount, 'Not enough money');
        balances[_sender] -= _amount;
        balances[_receiver] += _amount;
        emit hasTransfer(_sender, _receiver, _amount);
    }

    function transferBackToUser (address _receiver, uint _amount) public onlyPeerToPeerLendingContract {
        _transfer(peerToPeerLendingContractAddress, _receiver, _amount);
    }

    function transferToPeerToPeerLendingContract (address _sender, uint _amount) public onlyPeerToPeerLendingContract {
        _transfer(_sender, peerToPeerLendingContractAddress, _amount);
    }

}