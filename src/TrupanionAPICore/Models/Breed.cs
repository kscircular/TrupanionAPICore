using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.ComponentModel.DataAnnotations.Schema;

namespace TrupanionAPICore.Models
{
    public class Breed
    {
        public int Id { get; set; }

        public string Name { get; set; }
    }
}
