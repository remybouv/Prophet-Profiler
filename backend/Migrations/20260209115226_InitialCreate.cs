using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace ProphetProfiler.Api.Migrations
{
    /// <inheritdoc />
    public partial class InitialCreate : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "BoardGames",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "TEXT", nullable: false),
                    Name = table.Column<string>(type: "TEXT", maxLength: 100, nullable: false),
                    Description = table.Column<string>(type: "TEXT", nullable: true),
                    PhotoUrl = table.Column<string>(type: "TEXT", nullable: true),
                    MinPlayers = table.Column<int>(type: "INTEGER", nullable: false),
                    MaxPlayers = table.Column<int>(type: "INTEGER", nullable: false),
                    AverageDuration = table.Column<int>(type: "INTEGER", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "TEXT", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_BoardGames", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Players",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "TEXT", nullable: false),
                    Name = table.Column<string>(type: "TEXT", maxLength: 50, nullable: false),
                    PhotoUrl = table.Column<string>(type: "TEXT", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "TEXT", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Players", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "GameProfiles",
                columns: table => new
                {
                    BoardGameId = table.Column<Guid>(type: "TEXT", nullable: false),
                    Aggressivity = table.Column<int>(type: "INTEGER", nullable: false),
                    Patience = table.Column<int>(type: "INTEGER", nullable: false),
                    Analysis = table.Column<int>(type: "INTEGER", nullable: false),
                    Bluff = table.Column<int>(type: "INTEGER", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_GameProfiles", x => x.BoardGameId);
                    table.ForeignKey(
                        name: "FK_GameProfiles_BoardGames_BoardGameId",
                        column: x => x.BoardGameId,
                        principalTable: "BoardGames",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "GameSessions",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "TEXT", nullable: false),
                    Date = table.Column<DateTime>(type: "TEXT", nullable: false),
                    Location = table.Column<string>(type: "TEXT", nullable: true),
                    Notes = table.Column<string>(type: "TEXT", nullable: true),
                    Status = table.Column<int>(type: "INTEGER", nullable: false),
                    BoardGameId = table.Column<Guid>(type: "TEXT", nullable: false),
                    WinnerId = table.Column<Guid>(type: "TEXT", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    CompletedAt = table.Column<DateTime>(type: "TEXT", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_GameSessions", x => x.Id);
                    table.ForeignKey(
                        name: "FK_GameSessions_BoardGames_BoardGameId",
                        column: x => x.BoardGameId,
                        principalTable: "BoardGames",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_GameSessions_Players_WinnerId",
                        column: x => x.WinnerId,
                        principalTable: "Players",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.SetNull);
                });

            migrationBuilder.CreateTable(
                name: "PlayerProfiles",
                columns: table => new
                {
                    PlayerId = table.Column<Guid>(type: "TEXT", nullable: false),
                    Aggressivity = table.Column<int>(type: "INTEGER", nullable: false),
                    Patience = table.Column<int>(type: "INTEGER", nullable: false),
                    Analysis = table.Column<int>(type: "INTEGER", nullable: false),
                    Bluff = table.Column<int>(type: "INTEGER", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PlayerProfiles", x => x.PlayerId);
                    table.CheckConstraint("CK_PlayerProfile_Aggressivity", "[Aggressivity] BETWEEN 1 AND 5");
                    table.CheckConstraint("CK_PlayerProfile_Analysis", "[Analysis] BETWEEN 1 AND 5");
                    table.CheckConstraint("CK_PlayerProfile_Bluff", "[Bluff] BETWEEN 1 AND 5");
                    table.CheckConstraint("CK_PlayerProfile_Patience", "[Patience] BETWEEN 1 AND 5");
                    table.ForeignKey(
                        name: "FK_PlayerProfiles_Players_PlayerId",
                        column: x => x.PlayerId,
                        principalTable: "Players",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "PlayerStats",
                columns: table => new
                {
                    PlayerId = table.Column<Guid>(type: "TEXT", nullable: false),
                    BoardGameId = table.Column<Guid>(type: "TEXT", nullable: false),
                    TotalGamesPlayed = table.Column<int>(type: "INTEGER", nullable: false),
                    GamesWon = table.Column<int>(type: "INTEGER", nullable: false),
                    TotalBetsPlaced = table.Column<int>(type: "INTEGER", nullable: false),
                    BetsCorrect = table.Column<int>(type: "INTEGER", nullable: false),
                    LastUpdated = table.Column<DateTime>(type: "TEXT", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PlayerStats", x => new { x.PlayerId, x.BoardGameId });
                    table.ForeignKey(
                        name: "FK_PlayerStats_BoardGames_BoardGameId",
                        column: x => x.BoardGameId,
                        principalTable: "BoardGames",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_PlayerStats_Players_PlayerId",
                        column: x => x.PlayerId,
                        principalTable: "Players",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Bets",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "TEXT", nullable: false),
                    GameSessionId = table.Column<Guid>(type: "TEXT", nullable: false),
                    BettorId = table.Column<Guid>(type: "TEXT", nullable: false),
                    PredictedWinnerId = table.Column<Guid>(type: "TEXT", nullable: false),
                    IsCorrect = table.Column<bool>(type: "INTEGER", nullable: true),
                    PlacedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    PointsEarned = table.Column<int>(type: "INTEGER", nullable: false),
                    PlayerId = table.Column<Guid>(type: "TEXT", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Bets", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Bets_GameSessions_GameSessionId",
                        column: x => x.GameSessionId,
                        principalTable: "GameSessions",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_Bets_Players_BettorId",
                        column: x => x.BettorId,
                        principalTable: "Players",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Bets_Players_PlayerId",
                        column: x => x.PlayerId,
                        principalTable: "Players",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_Bets_Players_PredictedWinnerId",
                        column: x => x.PredictedWinnerId,
                        principalTable: "Players",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "SessionParticipants",
                columns: table => new
                {
                    ParticipantsId = table.Column<Guid>(type: "TEXT", nullable: false),
                    SessionsId = table.Column<Guid>(type: "TEXT", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SessionParticipants", x => new { x.ParticipantsId, x.SessionsId });
                    table.ForeignKey(
                        name: "FK_SessionParticipants_GameSessions_SessionsId",
                        column: x => x.SessionsId,
                        principalTable: "GameSessions",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_SessionParticipants_Players_ParticipantsId",
                        column: x => x.ParticipantsId,
                        principalTable: "Players",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_Bets_BettorId",
                table: "Bets",
                column: "BettorId");

            migrationBuilder.CreateIndex(
                name: "IX_Bets_GameSessionId",
                table: "Bets",
                column: "GameSessionId");

            migrationBuilder.CreateIndex(
                name: "IX_Bets_PlayerId",
                table: "Bets",
                column: "PlayerId");

            migrationBuilder.CreateIndex(
                name: "IX_Bets_PredictedWinnerId",
                table: "Bets",
                column: "PredictedWinnerId");

            migrationBuilder.CreateIndex(
                name: "IX_BoardGames_Name",
                table: "BoardGames",
                column: "Name",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_GameSessions_BoardGameId",
                table: "GameSessions",
                column: "BoardGameId");

            migrationBuilder.CreateIndex(
                name: "IX_GameSessions_WinnerId",
                table: "GameSessions",
                column: "WinnerId");

            migrationBuilder.CreateIndex(
                name: "IX_Players_Name",
                table: "Players",
                column: "Name",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_PlayerStats_BoardGameId",
                table: "PlayerStats",
                column: "BoardGameId");

            migrationBuilder.CreateIndex(
                name: "IX_SessionParticipants_SessionsId",
                table: "SessionParticipants",
                column: "SessionsId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "Bets");

            migrationBuilder.DropTable(
                name: "GameProfiles");

            migrationBuilder.DropTable(
                name: "PlayerProfiles");

            migrationBuilder.DropTable(
                name: "PlayerStats");

            migrationBuilder.DropTable(
                name: "SessionParticipants");

            migrationBuilder.DropTable(
                name: "GameSessions");

            migrationBuilder.DropTable(
                name: "BoardGames");

            migrationBuilder.DropTable(
                name: "Players");
        }
    }
}
