// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title Contrato de Billetera de Donaciones
/// @notice Este contrato permite a los usuarios realizar donaciones y consultar el saldo.
contract DonationWallet {
    address public owner; // Dirección del propietario del contrato
    uint256 public balance; // Saldo actual de la billetera

    /// @dev Evento emitido cuando se recibe una donación.
    /// @param donor Dirección del remitente de la donación.
    /// @param amount Monto de la donación en wei.
    event DonationReceived(address indexed donor, uint256 amount);

    /// @dev Constructor que establece al propietario del contrato.
    constructor() {
        owner = msg.sender;
    }

    /// @dev Función para que los usuarios realicen donaciones.
    /// @notice Esta función es payable, lo que permite enviar ether junto con la llamada.
    /// @notice Los fondos donados se agregan al saldo del contrato.
    function donate() public payable {
        require(msg.value > 0, "La donación debe ser mayor que cero");
        balance += msg.value;
        emit DonationReceived(msg.sender, msg.value);
    }

    /// @dev Función view para consultar el saldo actual de la billetera.
    /// @return El saldo actual en wei.
    function getBalance() public view returns (uint256) {
        return balance;
    }

    /// @dev Función para que el propietario retire fondos de la billetera.
    /// @param amount Monto a retirar en wei.
    function withdraw(uint256 amount) public {
        require(msg.sender == owner, "Solo el propietario puede retirar fondos");
        require(amount <= balance, "Saldo insuficiente");
        payable(owner).transfer(amount);
        balance -= amount;
    }

    /// @dev Función fallback que permite recibir ether sin datos adicionales.
    receive() external payable {
        // Esta función se ejecuta cuando alguien envía ether directamente al contrato.
        // Los fondos se consideran una donación y se agregan al saldo.
        donate();
    }
}
