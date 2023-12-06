/ SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TransparentePeruano {
    address public owner;
    
    // Estructura para representar un proyecto
    struct Project {
        string name;
        uint256 targetAmount;
        uint256 currentAmount;
        mapping(address => uint256) donations;
    }

    mapping(bytes32 => Project) public projects; // Mapping para almacenar proyectos por ID

    // Evento para registrar donaciones
    event DonationReceived(bytes32 projectId, address indexed donor, uint256 amount);

    // Modificador para garantizar que solo el propietario pueda realizar ciertas operaciones
    modifier onlyOwner() {
        require(msg.sender == owner, unicode"Solo el propietario puede realizar esta operación");
        _;
    }

    // Constructor que establece al creador del contrato como propietario
    constructor() {
        owner = msg.sender;
    }

    // Función para crear un nuevo proyecto
    function createProject(bytes32 projectId, string memory projectName, uint256 targetAmount) external onlyOwner {
        Project storage newProject = projects[projectId];
        newProject.name = projectName;
        newProject.targetAmount = targetAmount;
        newProject.currentAmount = 0;
    }

    // Función para realizar donaciones a un proyecto específico
    function donate(bytes32 projectId) external payable {
        Project storage project = projects[projectId];
        require(msg.value > 0, unicode"La donación debe ser mayor que cero");
        require(project.currentAmount + msg.value <= project.targetAmount, unicode"Se excede el objetivo de donación");

        project.donations[msg.sender] += msg.value;
        project.currentAmount += msg.value;

        emit DonationReceived(projectId, msg.sender, msg.value);
    }

    // Función para consultar el saldo actual de un proyecto
    function getProjectBalance(bytes32 projectId) external view returns (uint256) {
        return projects[projectId].currentAmount;
    }

    // Función para retirar fondos de un proyecto (solo permitido al propietario)
    function withdrawFunds(bytes32 projectId, uint256 amount) external onlyOwner {
        Project storage project = projects[projectId];
        require(amount <= project.currentAmount, "Saldo insuficiente en el proyecto");
        payable(owner).transfer(amount);
        project.currentAmount -= amount;
    }
    
}
