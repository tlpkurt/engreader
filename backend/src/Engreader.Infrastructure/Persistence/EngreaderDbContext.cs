using Engreader.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Storage.ValueConversion;
using Pgvector.EntityFrameworkCore;
using System.Text.Json;

namespace Engreader.Infrastructure.Persistence;

/// <summary>
/// Main database context for Engreader
/// </summary>
public class EngreaderDbContext : DbContext
{
    public EngreaderDbContext(DbContextOptions<EngreaderDbContext> options) : base(options)
    {
    }

    // Entity DbSets
    public DbSet<User> Users => Set<User>();
    public DbSet<Story> Stories => Set<Story>();
    public DbSet<Quiz> Quizzes => Set<Quiz>();
    public DbSet<QuizQuestion> QuizQuestions => Set<QuizQuestion>();
    public DbSet<QuizAttempt> QuizAttempts => Set<QuizAttempt>();
    public DbSet<UserProgress> UserProgress => Set<UserProgress>();
    public DbSet<Translation> Translations => Set<Translation>();
    public DbSet<UserEvent> UserEvents => Set<UserEvent>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Enable pgvector extension (optional - not required for basic functionality)
        // modelBuilder.HasPostgresExtension("vector");

        // Configure User entity
        modelBuilder.Entity<User>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.HasIndex(e => e.Email).IsUnique();
            entity.Property(e => e.Email).IsRequired().HasMaxLength(255);
            entity.Property(e => e.FirstName).IsRequired().HasMaxLength(100);
            entity.Property(e => e.LastName).IsRequired().HasMaxLength(100);
            entity.Property(e => e.Role).HasMaxLength(50);
            entity.HasQueryFilter(e => !e.IsDeleted);
        });

        // Configure Story entity
        modelBuilder.Entity<Story>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.HasOne(e => e.User).WithMany(u => u.Stories).HasForeignKey(e => e.UserId);
            entity.Property(e => e.Title).IsRequired().HasMaxLength(200);
            entity.Property(e => e.Topic).IsRequired().HasMaxLength(100);
            
            // Value converter for List<string> to JSON string
            var listConverter = new ValueConverter<List<string>, string>(
                v => JsonSerializer.Serialize(v, (JsonSerializerOptions?)null),
                v => JsonSerializer.Deserialize<List<string>>(v, (JsonSerializerOptions?)null) ?? new List<string>()
            );
            
            entity.Property(e => e.TargetWords)
                .HasConversion(listConverter)
                .HasColumnType("jsonb");
            
            entity.HasQueryFilter(e => !e.IsDeleted);
        });

        // Configure Quiz entity
        modelBuilder.Entity<Quiz>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.HasOne(e => e.Story).WithMany(s => s.Quizzes).HasForeignKey(e => e.StoryId);
            entity.HasQueryFilter(e => !e.IsDeleted);
        });

        // Configure QuizQuestion entity
        modelBuilder.Entity<QuizQuestion>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.HasOne(e => e.Quiz).WithMany(q => q.Questions).HasForeignKey(e => e.QuizId);
            entity.Property(e => e.CorrectAnswer).HasMaxLength(1);
            entity.HasQueryFilter(e => !e.IsDeleted);
        });

        // Configure QuizAttempt entity
        modelBuilder.Entity<QuizAttempt>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.HasOne(e => e.User).WithMany(u => u.QuizAttempts).HasForeignKey(e => e.UserId);
            entity.HasOne(e => e.Quiz).WithMany(q => q.Attempts).HasForeignKey(e => e.QuizId);
            
            // Value converter for Dictionary to JSON string (supports both PostgreSQL and In-Memory)
            // Changed from Dictionary<int, string> to Dictionary<string, string> for JSON compatibility
            var dictionaryConverter = new ValueConverter<Dictionary<string, string>, string>(
                v => JsonSerializer.Serialize(v, (JsonSerializerOptions?)null),
                v => JsonSerializer.Deserialize<Dictionary<string, string>>(v, (JsonSerializerOptions?)null) ?? new Dictionary<string, string>()
            );
            
            entity.Property(e => e.UserAnswers)
                .HasConversion(dictionaryConverter)
                .HasColumnType("jsonb");
            
            entity.HasQueryFilter(e => !e.IsDeleted);
        });

        // Configure UserProgress entity
        modelBuilder.Entity<UserProgress>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.HasOne(e => e.User).WithMany(u => u.ProgressRecords).HasForeignKey(e => e.UserId);
            entity.HasQueryFilter(e => !e.IsDeleted);
        });

        // Configure Translation entity
        modelBuilder.Entity<Translation>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.HasOne(e => e.Story).WithMany(s => s.Translations).HasForeignKey(e => e.StoryId).IsRequired(false);
            entity.HasIndex(e => new { e.SourceText, e.TargetLanguage });
            entity.HasQueryFilter(e => !e.IsDeleted);
        });

        // Configure UserEvent entity
        modelBuilder.Entity<UserEvent>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.HasOne(e => e.User).WithMany().HasForeignKey(e => e.UserId);
            
            // EventData is already string, no converter needed
            entity.Property(e => e.EventData).HasColumnType("jsonb");
            
            entity.HasIndex(e => e.EventTime);
            entity.HasQueryFilter(e => !e.IsDeleted);
        });
    }
}
