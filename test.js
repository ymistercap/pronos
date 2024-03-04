const { expect } = require("chai");

describe("SmartBet", function () {
  let smartBet;
  let admin;
  let user1;
  let user2;
  const matchId = 1;
  const teamA = 2;
  const teamB = 3;
  const participationAmount = ethers.utils.parseEther("1"); // Montant de participation (1 ETH)

  before(async () => {
    const SmartBet = await ethers.getContractFactory("SmartBet");
    [admin, user1, user2] = await ethers.getSigners(); // Obtenez les comptes de l'administrateur et des utilisateurs
    smartBet = await SmartBet.deploy();
    await smartBet.deployed();
  });

  it("Should register a user", async function () {
    await smartBet.connect(user1).registerUser();
    const user = await smartBet.users(user1.address);
    expect(user.userAddress).to.equal(user1.address);
  });

  it("Should make a prediction", async function () {
    await smartBet.connect(user1).makePrediction(teamA, teamB);
    const user = await smartBet.users(user1.address);
    expect(user.predictionTeamA).to.equal(teamA);
    expect(user.predictionTeamB).to.equal(teamB);
  });

  it("Should participate in the betting", async function () {
    await smartBet.connect(user1).participate({ value: participationAmount });
    const user = await smartBet.users(user1.address);
    expect(user.participationAmount).to.equal(participationAmount);
  });

  it("Should set match result", async function () {
    await smartBet.connect(admin).setMatchResult(matchId, teamA, teamB);
    const match = await smartBet.matches(matchId);
    expect(match.resultSubmitted).to.equal(true);
  });

  it("Should distribute prize to winner", async function () {
    // Pour tester la distribution du prix, nous devons simuler une prédiction correcte par l'utilisateur
    await smartBet.connect(user1).makePrediction(teamA, teamB);
    await smartBet.connect(user1).participate({ value: participationAmount });
    await smartBet.connect(admin).setMatchResult(matchId, teamA, teamB);
    await smartBet.checkPredictions(matchId); // Appel de la fonction checkPredictions pour vérifier les prédictions
    const userBalanceBefore = await ethers.provider.getBalance(user1.address);
    await smartBet.chooseRandomWinners(); // Appel de la fonction pour choisir aléatoirement 5 gagnants si nécessaire
    const userBalanceAfter = await ethers.provider.getBalance(user1.address);
    const prizeAmount = participationAmount.mul(95).div(100); // Calculer le montant du prix
    expect(userBalanceAfter.sub(userBalanceBefore)).to.equal(prizeAmount);
  });
});
