using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Engreader.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class AddValueConverters : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterDatabase()
                .OldAnnotation("Npgsql:PostgresExtension:vector", ",,");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterDatabase()
                .Annotation("Npgsql:PostgresExtension:vector", ",,");
        }
    }
}
