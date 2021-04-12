pragma solidity >= 0.7.0 <= 0.8.0;

interface IGCoin{
    function transferToPeerToPeerLendingContract(address _spender, uint _amount) external ;
    function transferBackToUser(address _receiver, uint _amount) external;
}
