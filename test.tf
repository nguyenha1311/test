terraform {
    backend "azurerm"{
        resource_group_name = "test-remote-state"
        storage_account_name = "hateststorageaccount1"
        container_name = "tfstate"
        key = "test.tfstate"
    }
}