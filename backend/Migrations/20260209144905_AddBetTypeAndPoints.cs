using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace ProphetProfiler.Api.Migrations
{
    /// <inheritdoc />
    public partial class AddBetTypeAndPoints : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "ChampionPoints",
                table: "PlayerStats",
                type: "INTEGER",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<int>(
                name: "OraclePoints",
                table: "PlayerStats",
                type: "INTEGER",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<bool>(
                name: "IsAutoBet",
                table: "Bets",
                type: "INTEGER",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<int>(
                name: "Type",
                table: "Bets",
                type: "INTEGER",
                nullable: false,
                defaultValue: 0);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "ChampionPoints",
                table: "PlayerStats");

            migrationBuilder.DropColumn(
                name: "OraclePoints",
                table: "PlayerStats");

            migrationBuilder.DropColumn(
                name: "IsAutoBet",
                table: "Bets");

            migrationBuilder.DropColumn(
                name: "Type",
                table: "Bets");
        }
    }
}
