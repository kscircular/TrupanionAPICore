using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;


namespace TrupanionAPICore.Models
{
    public interface IPolicy
    {
        IActionResult Enroll(int PetOwnerId, string CountryCode);
        IActionResult Cancel(string PolicyNumber);
    }
}
