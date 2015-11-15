
/*===============================================================================
 *
 *      Code Comment Block Here.
 *      
 *      Generated by Code Generator on 23/07/2014 11:43  
 * 
 *===============================================================================
 */

using System;

namespace FeatureDemandPlanning.Model
{
    public class ChangeSet : BusinessObject
    {
        private string _updatedBy;  

        public int SetId { get; set; } 
        public int OXODocId { get; set; }
        public string Section { get; set; }
        public decimal VersionId { get; set; }
        public string Reminder { get; set; }
        public bool IsImportant { get; set; }
        public bool IsStarred { get; set; }

        public string VersionLabel
        {
            get { return String.Format("v{0:N1}", VersionId); }
            
        }

        public new string UpdatedBy
        {
            get { return _updatedBy; }
            set { _updatedBy = value; }
        }

        public new string LastUpdated
        {
            get {

                if (base.LastUpdated.HasValue)
                    return base.LastUpdated.Value.ToString("yyyy-MM-dd HH:mm");
                else
                    return "";
            }
        }

        public OXODataItem[] DataItem { get; set; }

        // A blank constructor
        public ChangeSet() {;}
    }

    public class ChangeSetDetail : BusinessObject
    {
        public int SetId { get; set; }
        public decimal VersionId { get; set; }
        public string Reminder { get; set; }
        public string MarketName { get; set; }
        public string ModelName { get; set; }
        public string FeatureName { get; set; }
        public string PrevFitment { get; set; }
        public string CurrFitment { get; set; }

        // A blank constructor
        public ChangeSetDetail() { ;}

        public string VersionLabel
        {
            get { return String.Format("v{0:N1}", VersionId); }

        }
    }

    public class ChangeSetDownload : BusinessObject
    {
        private string _updatedBy;  

        public int SetId { get; set; }
        public DateTime LastUpdated { get; set; }
        public string MarketName { get; set; }
        public string ModelName { get; set; }
        public string FeatureName { get; set; }
        public string PrevFitment { get; set; }
        public string CurrFitment { get; set; }
        public decimal VersionId { get; set; }
        public string Reminder { get; set; }

        // A blank constructor
        public ChangeSetDownload() { ;}

        public string ChangeSetLabel
        {
            get { return SetId.ToString("0000000000"); }

        }

        public string VersionLabel
        {
            get { return String.Format("v{0:N1}", VersionId); }

        }

        public string LastUpdatedLabel
        {
            get { return LastUpdated.ToShortDateString() + " " + LastUpdated.ToShortTimeString(); }

        }

        public new string UpdatedBy
        {
            get { return _updatedBy; }
            set { _updatedBy = value; }
        }


    }
}