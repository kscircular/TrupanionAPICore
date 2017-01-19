using Microsoft.EntityFrameworkCore;
using TrupanionAPICore.Models;

namespace TrupanionAPICore.Data

{
    public class TrupanionContext : DbContext
    {
        public TrupanionContext(DbContextOptions<TrupanionContext> options) : base(options)
        {
        }

        public DbSet<Breed> Breed { get; set; }

    }
}