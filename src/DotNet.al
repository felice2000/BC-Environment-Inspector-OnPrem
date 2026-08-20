dotnet
{
    assembly(mscorlib)
    {
        type(System.Environment; DotNetEnvironment)
        {
        }

        type(Microsoft.Win32.RegistryKey; DotNetRegistryKey)
        {
        }

        type(Microsoft.Win32.RegistryHive; DotNetRegistryHive)
        {
        }

        type(Microsoft.Win32.RegistryView; DotNetRegistryView)
        {
        }
    }

    assembly(System.Management)
    {
        type(System.Management.ManagementObjectSearcher; DotNetManagementObjectSearcher)
        {
        }

        type(System.Management.ManagementObjectCollection; DotNetManagementObjectCollection)
        {
        }

        type(System.Management.ManagementObject; DotNetManagementObject)
        {
        }
    }
}