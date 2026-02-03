using Microsoft.EntityFrameworkCore;
using ProphetProfiler.Api.Data;
using ProphetProfiler.Api.Services;

var builder = WebApplication.CreateBuilder(args);

// Add services
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

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
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseCors("FlutterApp");
app.UseAuthorization();
app.MapControllers();

app.Run();