pragma solidity >= 0.7.0 <= 0.8.0;

import './DoMath.sol';
import './Ownable.sol';
import './IGCoin.sol';
import './GCoin.sol';

contract PeerToPeerLendingContract  is Ownable{
    using DoMath for uint256;

    uint256 private lendingContractId ;
    address public _gCoinContractAddress;

    constructor (address _addressContract) {
        _gCoinContractAddress = _addressContract ;
    }

    GCoin public gcoin;

    address public lender;

    struct LendingContract {
        uint256 _amount;
        uint256 _ltvRate;
        uint256 _dailyInterest;
        uint256 _amountETH;
        uint256 _loanDate;
        uint256 _durationDate;
        bool _isExpried;
        address _creator;
        address _borrower;
        bool _isActive;
        uint256 _loanOutOfDate;
        bool _isRepay;
    }

    modifier onlyLender () {
        lender = msg.sender;
        _;
    }

    mapping (uint256 => LendingContract)  public  lendingContracts;

    event LendOfferCreated(
        uint256 _id,
        uint256 _amount,
        uint256 _ltvRate,
        uint256 _amountETH,
        address _creator
    );

    event OfferActive(
        uint256 _id,
        address _borrower,
        uint256 _amountETH,
        uint256 _loanExpDate
    );

    event OfferRepaid(uint256 _id, uint256 _total);

    function getLendingContractCount (uint256 _id) public view returns (
        uint256,
        uint256,
        uint256,
        uint256,
        uint256,
        bool,
        address
        ) {
        return 
        (        
                lendingContracts[_id]._amount,
                lendingContracts[_id]._ltvRate,
                lendingContracts[_id]._dailyInterest,
                lendingContracts[_id]._loanDate,
                lendingContracts[_id]._loanOutOfDate,
                lendingContracts[_id]._isExpried,
                lendingContracts[_id]._creator
        );
    }

    function createLendingOffer (
        uint256 _amount_,
        uint256 _ltvRate_,
        uint256 _dailyInterest_,
        uint256 _duration_
        ) public onlyOwner returns (uint256){
            uint256 _id = lendingContractId++;
            uint256 _amountETH_ = _amount_.div(_ltvRate_);
            lendingContracts[_id] = LendingContract ({
                _amount : _amount_,
                _ltvRate : _ltvRate_,
                _amountETH : _amountETH_,
                _durationDate : _duration_,
                _creator: msg.sender,
                _isActive : true,
                _borrower: msg.sender,
                _dailyInterest : _dailyInterest_,
                _loanDate : 0,
                _loanOutOfDate : 0,
                _isExpried: false,
                _isRepay :false
            });
            emit LendOfferCreated(
                _id,
                _amount_,
                _ltvRate_,
                _amountETH_,
                msg.sender
                );
        IGCoin(_gCoinContractAddress).transferToPeerToPeerLendingContract(
            msg.sender,
            _amount_
            );

            return _id;
        }

    function borrowed (uint256 _id) public payable {
        address _borrower = msg.sender;
        LendingContract storage offer = lendingContracts[_id];

        require(offer._isActive == false, 'Offer was borrowed ');
        require(msg.value > offer._amountETH, 'Not enough ETH');

        IGCoin(_gCoinContractAddress).transferToPeerToPeerLendingContract(
            _borrower, offer._amount);

        offer._isActive = true;
        offer._loanDate = block.timestamp;
        offer._amountETH = msg.value;
        offer._borrower = msg.sender;
        offer._loanOutOfDate = block.timestamp.add(offer._durationDate);

        emit OfferActive(_id, _borrower, msg.value, offer._loanDate);
    }    

    function repay (uint256 _id) public {
        LendingContract storage offer = lendingContracts[_id];
        require(msg.sender == offer._borrower, "You are not borrower");
        require(offer._isRepay == false, 'Offer is repayed ');

        uint256 totalRepay;
        uint256 loanDayAmount = (block.timestamp.sub(offer._loanDate)).div(86400);

        if(loanDayAmount  < offer._loanOutOfDate){
            uint256 dailyInterestTotal = (loanDayAmount.mul(offer._dailyInterest))
            .mul(offer._amount.div(100));
            uint256 repayEarly =  (offer._amount.div(100)).mul(5);
            totalRepay = dailyInterestTotal.add(repayEarly);
        }
        totalRepay = (loanDayAmount.mul(offer._dailyInterest)).mul(offer._amount.div(100));
        lendingContracts[_id]._isRepay = true;

        // repay coin to contract
        IGCoin(_gCoinContractAddress)
        .transferToPeerToPeerLendingContract(msg.sender, totalRepay);

        // repay coin to lender
        IGCoin(_gCoinContractAddress)
        .transferBackToUser(offer._creator, totalRepay);

        // borrower receive ETH 
        payable(msg.sender).transfer(offer._amountETH);

        emit OfferRepaid(_id, totalRepay);
    } 
}