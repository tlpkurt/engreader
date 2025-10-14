using Microsoft.AspNetCore.Mvc;

namespace Engreader.Api.Controllers;

[ApiController]
[Route("api/v1/[controller]")]
public abstract class ApiControllerBase : ControllerBase
{
}
