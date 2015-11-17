
/*===============================================================================
 *
 *      Code Comment Block Here.
 *      
 *      Generated by Code Generator on 03/06/2014 12:52  
 * 
 *===============================================================================
 */

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using FeatureDemandPlanning.Model.Dapper;
using System.Web.Script.Serialization;

namespace FeatureDemandPlanning.Model
{
    public class ModelTransmission : BusinessObject
    {
        public string TypeName { get { return "ModelTransmission"; } }

        public int ProgrammeId { get; set; }
        public string Type { get; set; }
        public string Drivetrain { get; set; }
            
        // A blank constructor
        public ModelTransmission() {;}

        public string Name
        {
            get { return string.Format("{0} {1}", Drivetrain, Type); }

        }
    }
}