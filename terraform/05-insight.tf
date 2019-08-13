# Create Application Insights resource
resource "azurerm_application_insights" "demo" {
  name                = "tf-demo-appinsights"
  location            = "West Europe"
  resource_group_name = azurerm_resource_group.demo-terraform-resource-group.name
  application_type    = "Node.JS"
}

resource "azurerm_application_insights_api_key" "full_permissions" {
  name                    = "tf-test-appinsights-full-permissions-api-key"
  application_insights_id = "${azurerm_application_insights.demo.id}"
  read_permissions        = ["agentconfig", "aggregate", "api", "draft", "extendqueries", "search"]
  write_permissions       = ["annotations"]
}

output "instrumentation_key" {
  value = "${azurerm_application_insights.demo.instrumentation_key}"
}

output "app_id" {
  value = "${azurerm_application_insights.demo.app_id}"
}

output "full_permissions_api_key" {
  value = "${azurerm_application_insights_api_key.full_permissions.api_key}"
}
