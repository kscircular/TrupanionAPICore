using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using TrupanionAPICore.Models;

// For more information on enabling Web API for empty projects, visit http://go.microsoft.com/fwlink/?LinkID=397860

namespace TrupanionAPICore.Controllers
{
    [Route("api/[controller]")]
    public class PetController : Controller, IPet
    {
        public IPet Repo { get; set; }

        public PetController(IPet repo)
        {
            Repo = repo;
        }

        [HttpPut]
        public IActionResult AddPet([FromBody] int PetOwnerId, [FromBody] String Name, [FromBody] DateTime DateOfBirth, [FromBody] string BreedName)
        {
            Repo.AddPet(PetOwnerId, Name, DateOfBirth, BreedName);
            return NoContent();
        }

        public IActionResult RemovePet(int PetOwnerId, int PetId)
        {
            throw new NotImplementedException();
        }

        public IActionResult TransferOwnership(int OrgPetOwnerId, int NewPetOwnerId)
        {
            throw new NotImplementedException();
        }
    }
}

