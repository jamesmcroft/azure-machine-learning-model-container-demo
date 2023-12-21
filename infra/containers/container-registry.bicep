@description('Name of the resource.')
param name string
@description('Location to deploy the resource. Defaults to the location of the resource group.')
param location string = resourceGroup().location
@description('Tags for the resource.')
param tags object = {}

type roleAssignmentInfo = {
    roleDefinitionId: string
    principalId: string
}

type skuInfo = {
    name: 'Basic' | 'Premium' | 'Standard'
}

@description('Whether to enable an admin user that has push and pull access. Defaults to false.')
param adminUserEnabled bool = false
@description('Whether to allow public network access. Defaults to Enabled.')
@allowed([
    'Disabled'
    'Enabled'
])
param publicNetworkAccess string = 'Enabled'
@description('Container Registry SKU. Defaults to Basic.')
param sku skuInfo = {
    name: 'Basic'
}
@description('Role assignments to create for the Container Registry.')
param roleAssignments roleAssignmentInfo[] = []

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2022-12-01' = {
    name: name
    location: location
    tags: tags
    identity: {
        type: 'SystemAssigned'
    }
    sku: sku
    properties: {
        adminUserEnabled: adminUserEnabled
        publicNetworkAccess: publicNetworkAccess
    }
}

resource assignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for roleAssignment in roleAssignments: {
    name: guid(containerRegistry.id, roleAssignment.principalId, roleAssignment.roleDefinitionId)
    scope: containerRegistry
    properties: {
        principalId: roleAssignment.principalId
        roleDefinitionId: roleAssignment.roleDefinitionId
        principalType: 'ServicePrincipal'
    }
}]

@description('The deployed Container Registry resource.')
output resource resource = containerRegistry
@description('ID for the deployed Container Registry resource.')
output id string = containerRegistry.id
@description('Name for the deployed Container Registry resource.')
output name string = containerRegistry.name
@description('Login server for the deployed Container Registry resource.')
output loginServer string = containerRegistry.properties.loginServer
