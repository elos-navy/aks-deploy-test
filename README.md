# AKS deployment test

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Felos-tech%2Faks-deploy-test%2Fmaster%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Felos-tech%2Faks-deploy-test%2Fmaster%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

## Prerekvizity

* Registracia aplikacie (service principal) + priradenie role. Do formularu je nutne ziskat udaje ID a Secret key vytvorenej registracie v AD. Navod ako na to: https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal

## Troubleshooting

### Podporovana verzia kubernetes

Provisioning moze skoncit nasledujucou chybou: 'The value of parameter orchestratorProfile.OrchestratorVersion is invalid'. Vtedy je nutne pozriet sa na podporovane verzie kubernetes v regionu:

```
az aks get-versions --location westeurope --output table
```

A podporovanu verziu zadat do formularu. Podporovane verzie sa casom menia!

