

using FinHelper.Models;
using FinHelper.Models.Budget;
using FinHelper.Models.Category;
using FinHelper.Models.Transaction;
using FinHelper.Models.User;
using Microsoft.EntityFrameworkCore;

namespace FinHelper.Data;

public class ApplicationDbContext : DbContext
{
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options)
        {
        }
        
        public DbSet<User> Users { get; set; }
        public DbSet<Transaction> Transactions { get; set; }
        public DbSet<Category> Categories { get; set; }
        public DbSet<Budget> Budgets { get; set; }
        // public DbSet<Receipt> Receipts { get; set; }
        // public DbSet<AIInsight> AIInsights { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            // Configure relationships
            modelBuilder.Entity<Transaction>()
                .HasOne(t => t.User)
                .WithMany(u => u.Transactions)
                .HasForeignKey(t => t.UserId)
                .OnDelete(DeleteBehavior.Cascade);
            
            modelBuilder.Entity<Budget>()
                .HasOne(b => b.User)
                .WithMany(u => u.Budgets)
                .HasForeignKey(b => b.UserId)
                .OnDelete(DeleteBehavior.Cascade);
            
            modelBuilder.Entity<Transaction>()
                .HasOne(t => t.Category)
                .WithMany(c => c.Transactions)
                .HasForeignKey(t => t.CategoryId)
                .OnDelete(DeleteBehavior.Restrict);
            
            modelBuilder.Entity<Budget>()
                .HasOne(b => b.Category)
                .WithMany(c => c.Budgets)
                .HasForeignKey(b => b.CategoryId)
                .OnDelete(DeleteBehavior.Restrict);
            
            // Seed initial categories
            modelBuilder.Entity<Category>().HasData(
                new Category { Id = Guid.NewGuid(), Name = "Food", Color = "#4CAF50", Icon = "utensils" },
                new Category { Id = Guid.NewGuid(), Name = "Transport", Color = "#2196F3", Icon = "bus" },
                new Category { Id = Guid.NewGuid(), Name = "Entertainment", Color = "#9C27B0", Icon = "film" },
                new Category { Id = Guid.NewGuid(), Name = "Housing", Color = "#FF9800", Icon = "home" },
                new Category { Id = Guid.NewGuid(), Name = "Education", Color = "#F44336", Icon = "book" },
                new Category { Id = Guid.NewGuid(), Name = "Other", Color = "#9E9E9E", Icon = "shopping-cart" }
            );
        }
}