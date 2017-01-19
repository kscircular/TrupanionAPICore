using TrupanionAPICore.Models;
using Microsoft.AspNetCore.Mvc;
using TrupanionAPICore.Data;
using System.Data.SqlClient;
using System;

namespace TrupanionAPICore.Repository
{

    public class PetRepository : IPet 
    {
        private readonly TrupanionContext _trupanionContext;
        private SqlConnection _dbConnection;

        public PetRepository(TrupanionContext context)
        {
            _trupanionContext = context;

            //Note this needs to be either injected or pulled in from app.config
            _dbConnection= new SqlConnection("Server=localhost\\MSSQL2012;Database=Trupanion;Trusted_Connection=True;");
        }

        public IActionResult AddPet(int PetOwnerId, string Name, DateTime DateOfBirth, string BreedName)
        {

            //Note: Using Core version of Ado.net. This is my first attempt at using the Net Core version of WebAPI.  Even EF has undergone
            //quite a few changes.  I would prefer to have use EF, but wanted to put something together quicky so I used ADO.Net Core.
            
            _dbConnection.Open();
            SqlCommand comm = new SqlCommand();
            comm.Parameters.Add(new SqlParameter() { ParameterName = "@PetOwnerId", Value = PetOwnerId });
            comm.Parameters.Add(new SqlParameter() { ParameterName = "@Name", Value = Name });
            comm.Parameters.Add(new SqlParameter() { ParameterName = "@DateOfBirth", Value = DateOfBirth });
            comm.Parameters.Add(new SqlParameter() { ParameterName = "@BreedName", Value = BreedName });
            comm.CommandText = "AddPet";
            comm.CommandType = System.Data.CommandType.StoredProcedure;
            comm.Connection = _dbConnection;
            comm.ExecuteNonQuery();
            _dbConnection.Close();

            return null;
        }

        public IActionResult RemovePet(int PetOwnerId, int PetId)
        {
            _dbConnection.Open();
            SqlCommand comm = new SqlCommand();
            comm.Parameters.Add(new SqlParameter() { ParameterName = "@PetOwnerId", Value = PetOwnerId });
            comm.Parameters.Add(new SqlParameter() { ParameterName = "@PetId", Value = PetId });
            comm.CommandText = "RemovePet";
            comm.CommandType = System.Data.CommandType.StoredProcedure;
            comm.Connection = _dbConnection;
            comm.ExecuteNonQuery();
            _dbConnection.Close();
            return null;
        }

        public IActionResult TransferOwnership(int OrgPetOwnerId, int NewPetOwnerId)
        {           
           _dbConnection.Open();
            SqlCommand comm = new SqlCommand();
            comm.Parameters.Add(new SqlParameter() { ParameterName = "@OriginalOwnerId", Value = OrgPetOwnerId });
            comm.Parameters.Add(new SqlParameter() { ParameterName = "@NewOwnerId", Value = NewPetOwnerId });
            comm.CommandText = "RemovePet";
            comm.CommandType = System.Data.CommandType.StoredProcedure;
            comm.Connection = _dbConnection;
            comm.ExecuteNonQuery();
            _dbConnection.Close();
            return null;

        }
    }
}
