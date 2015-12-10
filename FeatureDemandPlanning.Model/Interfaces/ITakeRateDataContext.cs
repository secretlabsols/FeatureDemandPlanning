﻿using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Context;
using FeatureDemandPlanning.Model.Filters;
using FeatureDemandPlanning.Model.Parameters;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.Model.Interfaces
{
    public interface ITakeRateDataContext
    {
        TakeRateSummary GetVolumeHeader(VolumeFilter filter);
        Task<PagedResults<TakeRateSummary>> ListTakeRateData(TakeRateFilter filter);
        Task<PagedResults<TakeRateSummary>> ListLatestTakeRateData();
        Task<IEnumerable<TakeRateStatus>> ListTakeRateStatuses();

        void SaveVolumeHeader(FdpVolumeHeader headerToSave);
        
        IVolume GetVolume(VolumeFilter filter);
        IVolume GetVolume(TakeRateFilter filter);
        void SaveVolume(IVolume volumeToSave);

        TakeRateDataItem GetDataItem(TakeRateFilter filter);
        TakeRateData ListVolumeData(VolumeFilter filter);
        void SaveData(TakeRateDataItem dataItemToSave);
        Task<IEnumerable<TakeRateDataItem>> SaveChangeset(TakeRateParameters parameters);

        IEnumerable<FdpOxoVolumeDataItemHistory> ListHistory(TakeRateDataItem forData);
        IEnumerable<TakeRateDataItemNote> ListNotes(TakeRateDataItem forData);

        OXODoc GetOxoDocument(VolumeFilter filter);
        IEnumerable<OXODoc> ListAvailableOxoDocuments(VehicleFilter filter);

        void ProcessMappedData(IVolume volumeToProcess);

        IEnumerable<SpecialFeature> ListSpecialFeatures(ProgrammeFilter programmeFilter);        
    }
}