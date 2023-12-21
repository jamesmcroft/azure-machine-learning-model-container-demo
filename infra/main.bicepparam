using './main.bicep'

param workloadName = 'machinelearning'
param location = 'uksouth'
param computeInstanceUsers = [
  {
    objectId: '00000000-0000-0000-0000-000000000000'
    tenantId: null
  }
]
