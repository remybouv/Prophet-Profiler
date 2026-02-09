using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using ProphetProfiler.Api.Data;
using ProphetProfiler.Api.Services;

var builder = WebApplication.CreateBuilder(args);

// Add services
builder.Services.AddControllers()
    .AddJsonOptions(options =>
    {
        options.JsonSerializerOptions.PropertyNamingPolicy = JsonNamingPolicy.CamelCase;
    });
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new() { Title = "Prophet & Profiler API", Version = "v1" });
});

// Database
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlite(builder.Configuration.GetConnectionString("DefaultConnection")));

// CORS for Flutter app
builder.Services.AddCors(options =>
{
    options.AddPolicy("FlutterApp", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

// Business Services
builder.Services.AddScoped<IMatchScoreCalculator, MatchScoreCalculator>();
builder.Services.AddScoped<IBetManager, BetManager>();
builder.Services.AddScoped<IRankingService, RankingService>();

var app = builder.Build();

// Configure pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI(c => c.SwaggerEndpoint("/swagger/v1/swagger.json", "Prophet & Profiler API v1"));
    
    // Ensure database is created
    //using var scope = app.Services.CreateScope();
    //var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    //db.Database.EnsureCreated();
}

using (var scope = app.Services.CreateScope())
{
    var services = scope.ServiceProvider;
    try
    {
        var context = services.GetRequiredService<AppDbContext>();
        context.Database.Migrate(); // Applique les migrations
    }
    catch (Exception ex)
    {
        var logger = services.GetRequiredService<ILogger<Program>>();
        logger.LogError(ex, "Une erreur s'est produite lors de la migration de la base de donn�es.");
    }
}

app.UseHttpsRedirection();
app.UseCors("FlutterApp");
app.UseAuthorization();
app.MapControllers();

app.MapGet("/health", () => "OK");

app.Run();