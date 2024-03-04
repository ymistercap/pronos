# SmartBet Contract

Ce projet contient un contrat Smart Contract écrit en Solidity qui permet de gérer des paris sur des matchs sportifs. Le contrat permet aux utilisateurs de s'inscrire, de faire des prédictions sur les résultats des matchs, de participer aux paris en fournissant une somme d'argent, de saisir les résultats des matchs et de distribuer les gains aux gagnants.

## Contenu du projet

- `SmartBet.sol`: Le contrat SmartBet contenant la logique pour gérer les paris sur les matchs sportifs.
- `hardhat.config.js`: La configuration Hardhat pour compiler, déployer et tester le contrat SmartBet.
- `secrets.json`: Un fichier JSON contenant les clés privées et les API keys pour se connecter au réseau Ethereum. (Note: Fournir votre propre fichier `secrets.json` avec les clés nécessaires)
- `deploy.js`: Un script JavaScript pour déployer le contrat SmartBet sur le réseau Ethereum.
- `test.js`: Des tests unitaires pour tester les fonctionnalités du contrat SmartBet.
- `README.md`: Ce fichier README pour fournir des informations sur le projet.

## Déploiement

1. Assurez-vous d'avoir Node.js et npm installés sur votre machine.
2. Clonez ce dépôt et accédez au répertoire du projet.
3. Installez les dépendances avec la commande `npm install`.
4. Assurez-vous de configurer votre propre fichier `secrets.json` avec les clés privées et les API keys nécessaires. Utilisez le modèle fourni dans `secrets.example.json`.
5. Utilisez la commande `npx hardhat run deploy.js --network sepolia` pour déployer le contrat SmartBet sur le réseau Ethereum.

## Tests

Pour exécuter les tests unitaires, utilisez la commande suivante :

```bash
npx hardhat test
```
