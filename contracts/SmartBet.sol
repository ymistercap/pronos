// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SmartBet {
    address public admin; // Adresse de l'administrateur du contrat

    struct User {
        address userAddress;
        uint predictionTeamA;
        uint predictionTeamB;
        uint participationAmount; // Montant de la participation de l'utilisateur
    }

    struct Match {
        uint matchId;
        uint scoreTeamA;
        uint scoreTeamB;
        bool resultSubmitted;
    }

    mapping(address => User) public users;
    mapping(uint => Match) public matches;
    address[] private userAddresses; // Liste des adresses des utilisateurs
    uint public totalParticipationAmount; // Montant total collecté des participations
    uint public totalWinners; // Nombre total de gagnants
    uint private randomNonce = 0; // Variable pour le tirage aléatoire

    event UserRegistered(address indexed userAddress);
    event UserPrediction(address indexed userAddress, uint predictionTeamA, uint predictionTeamB);
    event MatchResult(uint indexed matchId, uint scoreTeamA, uint scoreTeamB);
    event Winner(address indexed userAddress, uint matchId, uint predictionTeamA, uint predictionTeamB, uint scoreTeamA, uint scoreTeamB, uint prizeAmount);
    event Participation(address indexed userAddress, uint amount);
    event AdminUpdated(address indexed oldAdmin, address indexed newAdmin);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }

    constructor() {
        admin = msg.sender; // Définir l'adresse de déploiement comme administrateur initial
    }

    function updateAdmin(address _newAdmin) external onlyAdmin {
        require(_newAdmin != address(0), "Invalid admin address");
        address oldAdmin = admin;
        admin = _newAdmin;
        emit AdminUpdated(oldAdmin, _newAdmin);
    }

    function registerUser() external {
        require(users[msg.sender].userAddress == address(0), "User already registered");
        users[msg.sender] = User(msg.sender, 0, 0, 0);
        userAddresses.push(msg.sender); // Ajouter l'adresse de l'utilisateur à la liste
        emit UserRegistered(msg.sender);
    }

    function makePrediction(uint _predictionTeamA, uint _predictionTeamB) external {
        require(_predictionTeamA >= 0 && _predictionTeamB >= 0, "Invalid prediction");
        require(users[msg.sender].userAddress != address(0), "User not registered");
        emit UserPrediction(msg.sender, _predictionTeamA, _predictionTeamB);
    }

    function participate() external payable {
        require(msg.value > 0, "Invalid participation amount");
        users[msg.sender].userAddress = msg.sender; // Enregistrez l'utilisateur s'il ne l'est pas déjà
        users[msg.sender].participationAmount += msg.value; // Ajouter le montant de la participation de l'utilisateur
        totalParticipationAmount += msg.value; // Ajouter au montant total collecté des participations
        emit Participation(msg.sender, msg.value);
    }

    function setMatchResult(uint _matchId, uint _scoreTeamA, uint _scoreTeamB) external onlyAdmin {
        require(!matches[_matchId].resultSubmitted, "Result already submitted");
        matches[_matchId] = Match(_matchId, _scoreTeamA, _scoreTeamB, true);
        emit MatchResult(_matchId, _scoreTeamA, _scoreTeamB);
        
        // Vérifier les prédictions et déterminer les gagnants
        checkPredictions(_matchId);
    }

    function checkPredictions(uint _matchId) private {
        Match memory matchData = matches[_matchId];
        uint winningCount = 0; // Nombre de gagnants trouvés

        for (uint i = 0; i < userAddresses.length; i++) { // Itérer sur les adresses des utilisateurs
            address userAddress = userAddresses[i];
            User memory user = users[userAddress];
            
            if (user.predictionTeamA == matchData.scoreTeamA && user.predictionTeamB == matchData.scoreTeamB) {
                winningCount++;
                if (winningCount <= 5) {
                    // Distribuer le gain à l'utilisateur
                    distributePrize(userAddress, user.participationAmount);
                    emit Winner(userAddress, _matchId, user.predictionTeamA, user.predictionTeamB, matchData.scoreTeamA, matchData.scoreTeamB, user.participationAmount);
                }
            }
        }

        totalWinners = winningCount; // Mettre à jour le nombre total de gagnants
    }

    function distributePrize(address _winner, uint _amount) private {
        uint prizeAmount = (_amount * 95) / 100; // 95% du montant total de la participation
        payable(_winner).transfer(prizeAmount); // Transférer le gain à l'utilisateur
    }

    // Fonction pour choisir aléatoirement 5 gagnants si nécessaire
    function chooseRandomWinners() external onlyAdmin {
        require(totalWinners > 5, "No need to choose random winners");
        
        for (uint i = 0; i < 5; i++) {
            // Utiliser le blockhash comme source aléatoire
            uint randomIndex = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, randomNonce))) % totalWinners;
            address randomWinner = userAddresses[randomIndex];
            distributePrize(randomWinner, users[randomWinner].participationAmount);
            emit Winner(randomWinner, 0, 0, 0, 0, 0, users[randomWinner].participationAmount);
            randomNonce++; // Incrémenter le nonce pour la prochaine itération
        }
    }
}
