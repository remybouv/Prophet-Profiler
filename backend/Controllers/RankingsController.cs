using Microsoft.AspNetCore.Mvc;
using ProphetProfiler.Api.Services;

namespace ProphetProfiler.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class RankingsController : ControllerBase
{
    private readonly IRankingService _rankingService;
    
    public RankingsController(IRankingService rankingService)
    {
        _rankingService = rankingService;
    }
    
    [HttpGet("champions")]
    public async Task<ActionResult<List<RankingEntry>>> GetChampions([FromQuery] int top = 10)
    {
        var champions = await _rankingService.GetChampionsGlobalAsync(top);
        return Ok(champions);
    }
    
    [HttpGet("champions/{gameId}")]
    public async Task<ActionResult<List<RankingEntry>>> GetChampionsByGame(Guid gameId, [FromQuery] int top = 10)
    {
        var champions = await _rankingService.GetChampionsByGameAsync(gameId, top);
        return Ok(champions);
    }
    
    [HttpGet("oracles")]
    public async Task<ActionResult<List<RankingEntry>>> GetOracles([FromQuery] int top = 10)
    {
        var oracles = await _rankingService.GetOraclesGlobalAsync(top);
        return Ok(oracles);
    }
    
    [HttpGet("oracles/{gameId}")]
    public async Task<ActionResult<List<RankingEntry>>> GetOraclesByGame(Guid gameId, [FromQuery] int top = 10)
    {
        var oracles = await _rankingService.GetOraclesByGameAsync(gameId, top);
        return Ok(oracles);
    }
}