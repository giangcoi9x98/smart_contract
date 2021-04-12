pragma solidity >= 0.7.0 <= 0.8.0;

import './DoMath.sol';
import "./Ownable.sol";
import './IGCoin.sol';
contract PeerToPeerLendingContract  is Ownable{
    using DoMath for uint;

    uint private lendingContractId ;
    address public _gCoinContractAddress;
    constructor (address _addressContract) {
        _gCoinContractAddress = _addressContract ;
    }
    address public lender;

    struct LendingContract {
        string _descriptionContract;
        uint _amount;
        uint _exchangeRate;
        uint _interest;
        uint _requestedDate;
        uint _lastRepaymentDate;
        bool _isExpried;
        address _creator;
    }

    modifier onlyLender () {
        lender = msg.sender;
        _;
    }
    mapping (address => uint)  public balances;

    mapping (uint => LendingContract)  public  lendingContracts;

    event LendOfferCreated (uint _id);
    event getSender(address _sender);

    function getBalance (address _sender) public view returns (uint) {
        return balances[_sender];
    }

    function getLendingContractCount (uint _id) public view returns (
        uint,
        uint,
        uint,
        uint,
        uint,
        bool,
        address
        ) {
        return 
        (        
                lendingContracts[_id]._amount,
                lendingContracts[_id]._exchangeRate,
                lendingContracts[_id]._interest,
                lendingContracts[_id]._requestedDate,
                lendingContracts[_id]._lastRepaymentDate,
                lendingContracts[_id]._isExpried,
                lendingContracts[_id]._creator
        );
    }

    function createLendingOffer (
        string memory _decription_contract,
        uint _amount_,
        uint _exchange_rate,
        uint _interest_,
        uint _duration_second
        ) public onlyOwner returns (uint){
            uint _id = lendingContractId++;
            lendingContracts[_id] = LendingContract ({
                _descriptionContract : _decription_contract,
                _amount : _amount_,
                _exchangeRate : _exchange_rate,
                _interest : _interest_,
                _requestedDate : block.timestamp,
                _lastRepaymentDate: block.timestamp + _duration_second,
                _creator : msg.sender,
                _isExpried : false
            });
           _mint(_amount_);
            emit LendOfferCreated(_id);
            return _id;
        }

    function _mint (uint _amount) public onlyOwner {
        emit getSender(msg.sender);
        IGCoin(_gCoinContractAddress).transferToPeerToPeerLendingContract(msg.sender, _amount);
    }    
    
}