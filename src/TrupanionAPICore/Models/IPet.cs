using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;


namespace TrupanionAPICore.Models
{
    public interface IPet
    {
        IActionResult AddPet(int PetOwnerId, string Name, DateTime DateOfBirth, string BreedName);
        IActionResult RemovePet(int PetOwnerId, int PetId);
        IActionResult TransferOwnership(int OrgPetOwnerId, int NewPetOwnerId);
    }
}
