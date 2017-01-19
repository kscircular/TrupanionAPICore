using TrupanionAPICore.Models;
using Microsoft.AspNetCore.Mvc;
using TrupanionAPICore.Data;
using System.Data.SqlClient;
using System;

namespace TrupanionAPICore.Repository
{

    public class PolicyRepository : IPolicy
    {
        private readonly TrupanionContext _trupanionContext;
        private SqlConnection _dbConnection;

        public PolicyRepository(TrupanionContext context)
        {
            _trupanionContext = context;
            _dbConnection= new SqlConnection("Server=localhost\\MSSQL2012;Database=Trupanion;Trusted_Connection=True;");
        }

        public IActionResult Enroll(int PetOwnerId, string CountryCode)
        {
            _dbConnection.Open();
            SqlCommand comm = new SqlCommand();
            comm.Parameters.Add(new SqlParameter() { ParameterName = "@PetOwnerId", Value = PetOwnerId });
            comm.Parameters.Add(new SqlParameter() { ParameterName = "@CountryCode", Value = CountryCode });
            comm.CommandText = "Enroll";
            comm.CommandType = System.Data.CommandType.StoredProcedure;
            comm.Connection = _dbConnection;
            comm.ExecuteNonQuery();
            _dbConnection.Close();
            return null;
        }

        public IActionResult Cancel(string PolicyNumber)
        {
            _dbConnection.Open();
            SqlCommand comm = new SqlCommand();
            comm.Parameters.Add(new SqlParameter() { ParameterName = "@PolicyNumber", Value = PolicyNumber });
            comm.CommandText = "Cancel";
            comm.CommandType = System.Data.CommandType.StoredProcedure;
            comm.Connection = _dbConnection;
            comm.ExecuteNonQuery();
            _dbConnection.Close();
            return null;
        }

    }
}
