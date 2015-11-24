﻿"use strict";

var model = namespace("FeatureDemandPlanning.Import");

model.AddTrimAction = function (params) {
    var uid = 0;
    var privateStore = {};
    var me = this;

    privateStore[me.id = uid++] = {};
    privateStore[me.id].Config = params.Configuration;
    privateStore[me.id].ActionUri = params.ModalActionUri;
    privateStore[me.id].SelectedTrimLevel = "";
    privateStore[me.id].Parameters = params;

    me.action = function () {
        sendData(me.getActionUri(), me.getActionParameters());
    };
    me.displaySelectedTrimLevel = function () {
        $("#" + me.getIdentifierPrefix() + "_SelectedTrimLevel").html(me.getSelectedTrimLevel());
    };
    me.getActionParameters = function () {
        return $.extend({}, getData(), {
            "ImportTrim": me.getImportTrim(),
            "Level": me.getSelectedTrimLevel()
        });
    };
    me.getIdentifierPrefix = function () {
        return $("#Action_IdentifierPrefix").val();
    };
    me.getImportTrim = function () {
        return $("#" + me.getIdentifierPrefix() + "_ImportTrim").attr("data-target");
    };
    me.getActionUri = function () {
        return privateStore[me.id].ActionUri;
    };
    me.getParameters = function () {
        return privateStore[me.id].Parameters;
    };
    me.getSelectedTrim = function () {
        return me.getImportTrim();
    };
    me.getSelectedTrimLevel = function () {
        return privateStore[me.id].SelectedTrimLevel;
    };
    me.trimLevelSelectedEventHandler = function (sender) {
        me.setSelectedTrimLevel(parseInt($(sender.target).attr("data-target")));
        me.displaySelectedTrim();
    };
    me.initialise = function () {
        me.registerEvents();
        me.registerSubscribers();
    };
    me.onSuccessEventHandler = function (sender, eventArgs) {
        $("#Modal_Notify")
            .removeClass("alert-danger")
            .removeClass("alert-warning")
            .addClass("alert-success")
            .html("New derivative '" + me.getImportDerivativeCode() + "' added successfully")
            .show();
        $("#Modal_OK").hide();
        $("#Modal_Cancel").html("Close");
    };
    me.onErrorEventHandler = function (sender, eventArgs) {
        if (eventArgs.IsValidation) {
            $("#Modal_Notify")
                .removeClass("alert-danger")
                .removeClass("alert-success")
                .addClass("alert-warning").html(eventArgs.Message).show();
        } else {
            $("#Modal_Notify")
                .removeClass("alert-warning")
                .removeClass("alert-success")
                .addClass("alert-danger").html(eventArgs.Message).show();
        }
    };
    me.registerEvents = function () {
        var prefix = me.getIdentifierPrefix();
        $("#" + prefix + "_TrimLevelList").find("a.trimlevel-item").on("click", function (e) {
            me.trimLevelSelectedEventHandler(e);
            e.preventDefault();
        });
        $("#Modal_OK").unbind("click").on("click", me.action);
        $(document)
            .unbind("Success").on("Success", function (sender, eventArgs) { $(".subscribers-notify").trigger("OnSuccessDelegate", [eventArgs]); })
            .unbind("Error").on("Error", function (sender, eventArgs) { $(".subscribers-notify").trigger("OnErrorDelegate", [eventArgs]); })
    };
    me.registerSubscribers = function () {
        $("#Modal_Notify")
            .unbind("OnSuccessDelegate").on("OnSuccessDelegate", me.onSuccessEventHandler)
            .unbind("OnErrorDelegate").on("OnErrorDelegate", me.onErrorEventHandler)
    };
    me.setParameters = function (parameters) {
        privateStore[me.id].Parameters = parameters;
    };
    me.setSelectedTrimId = function (trimId) {
        privateStore[me.id].SelectedTrimId = trimId;
    };
    me.setSelectedTrim = function (trim) {
        privateStore[me.id].SelectedTrim = trim;
    };
    function getData() {
        var params = me.getParameters();
        if (params.Data != undefined)
            return JSON.parse(params.Data)

        return {};
    };
    function sendData(uri, params) {
        $.ajax({
            "dataType": "json",
            "async": true,
            "type": "POST",
            "url": uri,
            "data": params,
            "success": function (json) {
                $(document).trigger("Success", json);
            },
            "error": function (jqXHR, textStatus, errorThrown) {
                $(document).trigger("Error", JSON.parse(jqXHR.responseText));
            }
        });
    };
}