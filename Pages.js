/*****************************************************************************
Pages

Handles fetching and saving of pages.

******************************************************************************/
var pages = require("./JSONStorage.js").load("./storage/pages.json");

// Get permissions for a page
// userid - the user trying to access it
// path - path to the page
// returns:
// - status
// - canwrite
// - page
var getPage = function(userid, path) {
    if(userid === undefined || path === undefined || callback === undefined)
        return;

    // split the path into individual elements so we can iterate from the parent down to the child
    var pages = path.split("/");

    // assume we can write unless at one of the stages we find out we cannot
    var canWrite = true;

    // the collection we're currently looking in, will change to their children as we
    // go along
    var parentCollection = pages.object;
    var page = undefined;

    // loop through each path in the path
    for(var i = 0; i < pages.length; i++) {
        var pageName = pages[i];
        // fix up page name, trim off white space
        pageName = pageName.trim();
        // page names must have at least one character in them
        if(pageName.length === 0) {
            return {status: "nopage", write: false};
        }

        // find the page
        page = parentCollection[pageName];
        if(page === undefined) {
            // the page doesn't exist
            return {status: "nopage", write: canWrite};
        }

        // check the permissions, but don't check them if we're an administrator (since administrators
        // can access anything)
        var administrator = false;
        if(!administrator) {
            // permissions only count if there are permissions assigned to this page
            if(page.readUsers.length > 0 || page.writeUsers.length > 0) {
                var hasAccess = false;

                // check if we can write
                for(var j = 0; j < page.writeUsers.length && !hasAccess; j++) {
                    if(page.writeUsers[j] === userid) {
                        // we have write access
                        hasAccess = true;
                    }
                }

                if(!hasAccess) {
                    // we don't have write access
                    canWrite = false;

                    // check if we have read access
                    for(var j = 0; j < page.readUsers.length && !hasAccess; j++) {
                        if(pages.readUsers[j] === userid) {
                            // we have read access
                            hasAccess = true;
                        }
                    }

                    if(!hasAccess) {
                        // we have neither read nor write access
                        return {status: "nopermission", write: false};
                    }
                }
            }
        } // if(!administrator)

        parentCollection = page.children;
    } // for each page in path

    return {status: "success", write: canWrite, page: page};
};

// Loads a page.
// userid - the user trying to load the page
// path - the page's path
// redirect - true/false if we should follow redirections
// callback - callback after page has been loaded
exports.loadPage = function(userid, path, redirect, callback) {
    // look up the page
    var result = getPage(userid, path);

    if(result.status !== "success") {
        // it wasn't successful
        callback({status: result.status, write: result.write, fullpath: path});
        return;
    }
    
    // send back the latest copy of the page
    callback({
        status: "success",
        write: result.write,
        fullpath: path,
        pageContents: page.contents[page.contents.length - 1].text
        });
};

exports.createPage = function(userid, path, callback) {
    if(userid === undefined || path === undefined || callback === undefined)
        return

    var pagename; // the name of the page
    var parent = null; // the parent page

    // see if this is a child page
    var divider = path.lastIndexOf('/');

    
    if(divider != -1) {
        pagename = path.substring(divider + 1).trim();

        // this is a child page, look up the parent
        var result = getPage(userid, path);
        if(result.status !== "success") {
            // does not exist
            if(result.status === "noparent") {
                callback({status: "noparent"});
                return;
            }

            // some other error
            callback({status: "nopermission"});
            return;
        }
    } else {
        pagename = path.trim();
    }

    // check that the name of the page is valid
    if(pagename.length === 0) {
        callback({status: "nopermission"});
        return;
    }

    var collection; // the collection we want to add the page to
    if(parent !== null)
        collection = parent.children;
    else
        collection = pages.object;

    // check if the page already exists
    if(collection[pagename] !== undefined) {
        callback({status: "alreadyexists"});
        return;
    }

    // create this page
    var newPage = {
        contents: {
            userid: userid,
            date: (new Date()).toUTCString(),
            contents: ""
            },
        readUsers: {},
        writeUsers: {},
        children: {}
    };

    collection[pagename] = newPage;

    // invalidate the storage structure so it eventually flushes to disk
    pages.invalidate();

    callback({status: "success"});
};