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
    public class PolicyController : Controller
    {
        public IPolicy Repo { get; set; }

        public PolicyController(IPolicy repo)
        {
            Repo = repo;
        }

        [HttpPut("{id}/{country}")]
        public IActionResult Enroll(int id, string country)
        {
            Repo.Enroll(id,country);
            return NoContent();
        }

        [HttpDelete("{id}")]
        public IActionResult Cancel(string PolicyNumber)
        {
            Repo.Cancel(PolicyNumber);
            return NoContent();
        }

    }
}

