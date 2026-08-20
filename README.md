# BC Environment Inspector

A lightweight diagnostic extension for Microsoft Dynamics 365 Business Central On-Premises.

BC Environment Inspector provides a quick overview of the Business Central environment, Service Tier hardware, operating system, and SQL Server information from a single page.

The extension is intended primarily for administrators, consultants, developers, and support engineers working with Business Central On-Premises environments.

## Features

### Business Central

Displays information about the current Business Central environment:

- Application Version
- Environment Name
- Deployment Type
- Environment Type
- Application Family
- Current Company
- Current User

### Business Central Service Tier

Displays information about the server running the Business Central Service Tier:

- Server Name
- Operating System and Windows release
- CPU Model
- Logical Processors
- Total Physical Memory
- 64-bit Operating System
- 64-bit Business Central Process

Example:

```text
Server Name: SRV-BC01
Operating System: Windows Server 2022 21H2
CPU: Intel(R) Xeon(R) ...
Logical Processors: 16
Total RAM: 64.0 GB
64-bit OS: Yes
64-bit BC Process: Yes
```

### SQL Server

Displays information about the SQL Server instance:

- Server Name
- Instance Name
- SQL Server Version
- Product Version / Build
- Edition
- Business Central Database Name

Example:

```text
Server Name: SRV-SQL01
SQL Version: SQL Server 2022
Product Version: 16.0.x.x
Edition: Standard Edition (64-bit)
Database: BC_PROD
```

If SQL Server is using the default instance, the Instance field is left empty.

### Environment Report

The **Environment Info** action generates a formatted summary of the environment that can be used for troubleshooting, documentation, or support tickets.

Example:

```text
=== Business Central Environment ===

Business Central
Application Version: 28.4.53241.0
Environment Name: Production
Deployment Type: On-Premises
Environment Type: Production
Application Family: IT
Company: CRONUS Italia S.p.A.

Business Central Service Tier
Server Name: SRV-BC01
Operating System: Windows Server 2022 21H2
CPU: Intel(R) Xeon(R) ...
Logical Processors: 16
Total RAM: 64.0 GB
64-bit OS: Yes
64-bit BC Process: Yes

SQL Server
Server Name: SRV-SQL01
SQL Version: SQL Server 2022
Product Version: 16.0.x.x
Edition: Standard Edition (64-bit)
Database: BC_PROD
```

## Requirements

- Microsoft Dynamics 365 Business Central On-Premises
- `target: OnPrem`
- Windows-based Business Central Service Tier
- Access to Windows Management Instrumentation (WMI)
- Access to the Windows Registry
- SQL Server connectivity from the Business Central Service Tier

The extension uses .NET interoperability and therefore is **not compatible with Business Central SaaS**.

## .NET Dependencies

The project uses the following .NET assemblies:

- `mscorlib`
- `System.Management`
- `Microsoft.Data.SqlClient`

`Microsoft.Data.SqlClient.dll` is included with the Business Central Server installation.

For Business Central 28, it can normally be found at:

```text
C:\Program Files\Microsoft Dynamics 365 Business Central\280\Service\Microsoft.Data.SqlClient.dll
```

For local development, copy the required assembly to:

```text
.netpackages\
```

and configure the AL assembly probing paths in `.vscode/settings.json`.

Example:

```json
{
    "al.assemblyProbingPaths": [
        ".netpackages",
        "C:\\Program Files (x86)\\Reference Assemblies\\Microsoft\\Framework\\.NETFramework\\v4.8",
        "C:\\Windows\\Microsoft.NET\\Framework64\\v4.0.30319"
    ]
}
```

> The `.netpackages` directory should not be committed to the repository.

Add it to `.gitignore`:

```gitignore
.netpackages/
```

## SQL Server Authentication

SQL Server information is retrieved using Windows Integrated Authentication.

No SQL Server username or password is stored by the extension.

The Business Central Service Tier account must have sufficient access to connect to SQL Server and retrieve the requested server information.

## Installation

1. Clone the repository.

```powershell
git clone <repository-url>
```

2. Copy the required .NET assemblies to `.netpackages`.

3. Download the Business Central AL symbols.

4. Compile the extension using Visual Studio Code and the AL Language extension.

5. Publish the generated `.app` package to a Business Central On-Premises environment.

## Project Structure

```text
BC-Environment-Inspector-OnPrem/
├── .vscode/
│   └── settings.json
├── src/
│   ├── DotNet.al
│   ├── EnvironmentInfo.Page.al
│   └── EnvironmentInfoText.Page.al
├── .gitignore
├── app.json
├── LICENSE
└── README.md
```

## Security

The extension is designed as a read-only diagnostic tool.

It retrieves system and environment information but does not modify:

- Business Central configuration
- Windows configuration
- SQL Server configuration
- Business Central data

Because the extension exposes infrastructure information such as server names, hardware details, SQL Server versions, and database names, access to the Environment Inspector page should be restricted to appropriate administrative or technical users.

## Compatibility

The project is currently developed and tested against Business Central 28 On-Premises.

Other Business Central On-Premises versions may require changes to runtime versions, .NET assembly references, or AL APIs.

## Disclaimer

This project is an independent community project and is not affiliated with, endorsed by, or supported by Microsoft.

Microsoft Dynamics 365 Business Central, Windows, and SQL Server are trademarks of Microsoft Corporation.

## License

This project is licensed under the MIT License.

See the `LICENSE` file for details.
