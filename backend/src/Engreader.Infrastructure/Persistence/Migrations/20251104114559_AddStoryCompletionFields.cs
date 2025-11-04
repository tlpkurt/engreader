using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Engreader.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class AddStoryCompletionFields : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<bool>(
                name: "IsCompleted",
                table: "Stories",
                type: "boolean",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<int>(
                name: "ReadingTimeSeconds",
                table: "Stories",
                type: "integer",
                nullable: false,
                defaultValue: 0);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "IsCompleted",
                table: "Stories");

            migrationBuilder.DropColumn(
                name: "ReadingTimeSeconds",
                table: "Stories");
        }
    }
}
