extension radius

param environment string

@secure()
param registryPassword string

@secure()
param registryUsername string

resource storeApp 'Radius.Core/applications@2025-08-01-preview' = {
  name: 'aks-store-demo-2'
  properties: {
    environment: environment
  }
}

resource aiModel 'Radius.AI/models@2025-08-01-preview' = {
  name: 'model'
  properties: {
    application: storeApp.id
    codeReference: 'src/ai-service/routers/description_generator.py#L129'
    environment: environment
    model: 'gpt-5-mini'
  }
}

resource mongoDb 'Radius.Data/mongoDatabases@2025-08-01-preview' = {
  name: 'mongo'
  properties: {
    application: storeApp.id
    codeReference: 'src/makeline-service/mongodb.go#L149'
    database: 'orderdb'
    environment: environment
  }
}

resource rabbitmqQueue 'Radius.Messaging/rabbitMQ@2025-08-01-preview' = {
  name: 'rabbitmq'
  properties: {
    application: storeApp.id
    codeReference: 'src/order-service/plugins/messagequeue.js#L26'
    environment: environment
    queue: 'orders'
    username: 'radius'
  }
}

resource registryCreds 'Radius.Security/secrets@2025-08-01-preview' = {
  name: 'radius-ghcr-registry-creds'
  properties: {
    application: storeApp.id
    codeReference: 'src/order-service/Dockerfile'
    data: {
      password: {
        value: registryPassword
      }
      username: {
        value: registryUsername
      }
    }
    environment: environment
    kind: 'basicAuthentication'
  }
}

resource aiServiceImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'ai-service-image'
  properties: {
    application: storeApp.id
    build: {
      platforms: [
        'linux/amd64'
      ]
      source: 'git::https://github.com/nicolejms/aks-store-demo-2.git//src/ai-service?ref=867dc76c5c365c30bc8aef3ff570d7aa0c3fa522'
    }
    codeReference: 'src/ai-service/Dockerfile'
    environment: environment
  }
  dependsOn: [
    registryCreds
  ]
}

resource makelineServiceImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'makeline-service-image'
  properties: {
    application: storeApp.id
    build: {
      platforms: [
        'linux/amd64'
      ]
      source: 'git::https://github.com/nicolejms/aks-store-demo-2.git//src/makeline-service?ref=867dc76c5c365c30bc8aef3ff570d7aa0c3fa522'
    }
    codeReference: 'src/makeline-service/Dockerfile'
    environment: environment
  }
  dependsOn: [
    registryCreds
  ]
}

resource orderServiceImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'order-service-image'
  properties: {
    application: storeApp.id
    build: {
      platforms: [
        'linux/amd64'
      ]
      source: 'git::https://github.com/nicolejms/aks-store-demo-2.git//src/order-service?ref=867dc76c5c365c30bc8aef3ff570d7aa0c3fa522'
    }
    codeReference: 'src/order-service/Dockerfile'
    environment: environment
  }
  dependsOn: [
    registryCreds
  ]
}

resource productServiceImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'product-service-image'
  properties: {
    application: storeApp.id
    build: {
      platforms: [
        'linux/amd64'
      ]
      source: 'git::https://github.com/nicolejms/aks-store-demo-2.git//src/product-service?ref=867dc76c5c365c30bc8aef3ff570d7aa0c3fa522'
    }
    codeReference: 'src/product-service/Dockerfile'
    environment: environment
  }
  dependsOn: [
    registryCreds
  ]
}

resource storeAdminImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'store-admin-image'
  properties: {
    application: storeApp.id
    build: {
      platforms: [
        'linux/amd64'
      ]
      source: 'git::https://github.com/nicolejms/aks-store-demo-2.git//src/store-admin?ref=867dc76c5c365c30bc8aef3ff570d7aa0c3fa522'
    }
    codeReference: 'src/store-admin/Dockerfile'
    environment: environment
  }
  dependsOn: [
    registryCreds
  ]
}

resource storeFrontImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'store-front-image'
  properties: {
    application: storeApp.id
    build: {
      platforms: [
        'linux/amd64'
      ]
      source: 'git::https://github.com/nicolejms/aks-store-demo-2.git//src/store-front?ref=867dc76c5c365c30bc8aef3ff570d7aa0c3fa522'
    }
    codeReference: 'src/store-front/Dockerfile'
    environment: environment
  }
  dependsOn: [
    registryCreds
  ]
}

resource virtualCustomerImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'virtual-customer-image'
  properties: {
    application: storeApp.id
    build: {
      platforms: [
        'linux/amd64'
      ]
      source: 'git::https://github.com/nicolejms/aks-store-demo-2.git//src/virtual-customer?ref=867dc76c5c365c30bc8aef3ff570d7aa0c3fa522'
    }
    codeReference: 'src/virtual-customer/Dockerfile'
    environment: environment
  }
  dependsOn: [
    registryCreds
  ]
}

resource virtualWorkerImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'virtual-worker-image'
  properties: {
    application: storeApp.id
    build: {
      platforms: [
        'linux/amd64'
      ]
      source: 'git::https://github.com/nicolejms/aks-store-demo-2.git//src/virtual-worker?ref=867dc76c5c365c30bc8aef3ff570d7aa0c3fa522'
    }
    codeReference: 'src/virtual-worker/Dockerfile'
    environment: environment
  }
  dependsOn: [
    registryCreds
  ]
}

resource aiServiceContainer 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'ai-service'
  properties: {
    application: storeApp.id
    codeReference: 'src/ai-service/main.py#L17'
    containers: {
      ai: {
        env: {
          AZURE_OPENAI_API_KEY: {
            valueFrom: {
              secretKeyRef: {
                key: 'apiKey'
                secretName: aiModel.properties.secrets.name
              }
            }
          }
          AZURE_OPENAI_API_VERSION: {
            value: '2024-12-01-preview'
          }
          AZURE_OPENAI_DEPLOYMENT_NAME: {
            value: 'chat'
          }
          AZURE_OPENAI_ENDPOINT: {
            value: aiModel.properties.endpoint
          }
          USE_AZURE_OPENAI: {
            value: 'True'
          }
        }
        image: aiServiceImage.properties.imageReference
        ports: {
          web: {
            containerPort: 5001
          }
        }
      }
    }
    environment: environment
  }
}

resource makelineServiceContainer 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'makeline-service'
  properties: {
    application: storeApp.id
    codeReference: 'src/makeline-service/main.go#L21'
    containers: {
      makeline: {
        env: {
          ORDER_DB_COLLECTION_NAME: {
            value: 'orders'
          }
          ORDER_DB_NAME: {
            value: 'orderdb'
          }
          ORDER_DB_URI: {
            valueFrom: {
              secretKeyRef: {
                key: 'connectionString'
                secretName: mongoDb.properties.secrets.name
              }
            }
          }
          ORDER_QUEUE_NAME: {
            value: 'orders'
          }
          ORDER_QUEUE_PASSWORD: {
            valueFrom: {
              secretKeyRef: {
                key: 'password'
                secretName: rabbitmqQueue.properties.secrets.name
              }
            }
          }
          ORDER_QUEUE_URI: {
            value: 'amqp://${rabbitmqQueue.properties.host}:${rabbitmqQueue.properties.port}'
          }
          ORDER_QUEUE_USERNAME: {
            value: 'radius'
          }
        }
        image: makelineServiceImage.properties.imageReference
        ports: {
          web: {
            containerPort: 3001
          }
        }
      }
    }
    environment: environment
  }
}

resource orderServiceContainer 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'order-service'
  properties: {
    application: storeApp.id
    codeReference: 'src/order-service/app.js#L6'
    containers: {
      order: {
        env: {
          ORDER_QUEUE_HOSTNAME: {
            value: rabbitmqQueue.properties.host
          }
          ORDER_QUEUE_NAME: {
            value: 'orders'
          }
          ORDER_QUEUE_PASSWORD: {
            valueFrom: {
              secretKeyRef: {
                key: 'password'
                secretName: rabbitmqQueue.properties.secrets.name
              }
            }
          }
          ORDER_QUEUE_PORT: {
            value: string(rabbitmqQueue.properties.port)
          }
          ORDER_QUEUE_USERNAME: {
            value: 'radius'
          }
        }
        image: orderServiceImage.properties.imageReference
        ports: {
          web: {
            containerPort: 3000
          }
        }
      }
    }
    environment: environment
  }
}

resource productServiceContainer 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'product-service'
  properties: {
    application: storeApp.id
    codeReference: 'src/product-service/src/main.rs#L5'
    containers: {
      product: {
        env: {
          AI_SERVICE_URL: {
            value: 'http://${aiServiceContainer.properties.hosts.ai}:5001/'
          }
        }
        image: productServiceImage.properties.imageReference
        ports: {
          web: {
            containerPort: 3002
          }
        }
      }
    }
    environment: environment
  }
}

resource storeAdminContainer 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'store-admin'
  properties: {
    application: storeApp.id
    codeReference: 'src/store-admin/src/main.ts#L13'
    containers: {
      admin: {
        image: storeAdminImage.properties.imageReference
        ports: {
          web: {
            containerPort: 8081
          }
        }
      }
    }
    environment: environment
  }
}

resource storeFrontContainer 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'store-front'
  properties: {
    application: storeApp.id
    codeReference: 'src/store-front/src/main.ts#L13'
    containers: {
      front: {
        image: storeFrontImage.properties.imageReference
        ports: {
          web: {
            containerPort: 8080
          }
        }
      }
    }
    environment: environment
  }
}

resource virtualCustomerContainer 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'virtual-customer'
  properties: {
    application: storeApp.id
    codeReference: 'src/virtual-customer/src/main.rs#L7'
    containers: {
      customer: {
        env: {
          ORDERS_PER_HOUR: {
            value: '30'
          }
          ORDER_SERVICE_URL: {
            value: 'http://${orderServiceContainer.properties.hosts.order}:3000/'
          }
        }
        image: virtualCustomerImage.properties.imageReference
      }
    }
    environment: environment
  }
}

resource virtualWorkerContainer 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'virtual-worker'
  properties: {
    application: storeApp.id
    codeReference: 'src/virtual-worker/src/main.rs#L6'
    containers: {
      worker: {
        env: {
          MAKELINE_SERVICE_URL: {
            value: 'http://${makelineServiceContainer.properties.hosts.makeline}:3001'
          }
          ORDERS_PER_HOUR: {
            value: '20'
          }
        }
        image: virtualWorkerImage.properties.imageReference
      }
    }
    environment: environment
  }
}

resource storeAdminRoute 'Radius.Compute/routes@2025-08-01-preview' = {
  name: 'store-admin-route'
  properties: {
    application: storeApp.id
    codeReference: 'aks-store-all-in-one.yaml#L508'
    environment: environment
    kind: 'HTTP'
    rules: [
      {
        destinationContainer: {
          containerName: 'admin'
          containerPort: 8081
          resourceId: storeAdminContainer.id
        }
        matches: [
          {
            httpPath: '/'
          }
        ]
      }
    ]
  }
}

resource storeFrontRoute 'Radius.Compute/routes@2025-08-01-preview' = {
  name: 'store-front-route'
  properties: {
    application: storeApp.id
    codeReference: 'aks-store-all-in-one.yaml#L445'
    environment: environment
    kind: 'HTTP'
    rules: [
      {
        destinationContainer: {
          containerName: 'front'
          containerPort: 8080
          resourceId: storeFrontContainer.id
        }
        matches: [
          {
            httpPath: '/'
          }
        ]
      }
    ]
  }
}
