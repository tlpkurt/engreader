namespace Engreader.Background;

/// <summary>
/// Background worker for scheduled tasks
/// </summary>
public class Worker : BackgroundService
{
    private readonly ILogger<Worker> _logger;

    public Worker(ILogger<Worker> logger)
    {
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            if (_logger.IsEnabled(LogLevel.Information))
            {
                _logger.LogInformation("Engreader Background Worker running at: {time}", DateTimeOffset.Now);
            }
            await Task.Delay(60000, stoppingToken); // Run every minute
        }
    }
}
