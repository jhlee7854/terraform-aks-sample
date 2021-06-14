## Azure Storage에 Terraform 상태 저장하기

scipts 디렉터리 하위의 `terraform-azure-strage-account.sh`를 실행한다.
실행하기 전 스크립트의 변수를 자신의 환경에 맞게 설정한다.
스크립트 실행 결과 출력은 `main.tf`에서 terraform backend 설정에 사용되므로 출력 결과를 가지고 main.tf를 상황에 맞게 설정한다.
스크립트 실행 결과 출력 중 Storage account에 접근할 수 있는 `access_key`는 terraform 작업 중 필요하므로 다음과 같이 `ARM_ACCESS_KEY`이라는 환경변수로 저장한다.

```shell
export ARM_ACCESS_KEY=<storage access key>
```

## Required Variables

`terraform.tfvars` 파일을 생성하고 아래 변수들을 복사하여 상황에 맞게 설정한다.

```shell
environment = "dev"

# Network Variables
address_space = [
  "10.0.0.0/16"
]
aks_subnet_address_prefixes = [
  "10.0.1.0/24"
]

# AKS Variables
ssh_public_key = "~/.ssh/id_rsa.pub"
aks_kubernetes_version = "1.19.9"
aks_max_count = 9
aks_min_count = 1
aks_node_count = 3
aks_vm_size = "Standard_D2_v2"
log_analytics_workspace_sku = "PerGB2018"
```

## Terraform graph

다음 커맨드를 이용하면 terraform 설정 또는 실행 계획을 시각적으로 확인할 수 있는 출력을 얻을 수 있다.

```shell
terraform graph
```

위 커맨드를 이용하여 다음과 같이 시각화 도구와 연동하여 그래프가 시각적으로 표현된 이미지를 얻을 수 있다.

```shell
terraform graph | dot -Tsvg > graph.svg
```

### References

[https://terraform.io](https://terraform.io)

[Tutorial: Azure Storage에 Terraform 상태 저장하기](https://docs.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage)