#
# expressions to make a skelesim object from input$xxxx variables
#
# in general, wait till one of the inputs is changed and then alter the ssClass component of rValues
#general skelesim parameters


####This section updates the ssClass reactive when inputs change

observeEvent(input$title, {
    rValues$ssClass@title <- input$title
})
observeEvent(input$quiet, {
    rValues$ssClass@quiet <- input$quiet
})
             
observeEvent(input$coalescent,{
    rValues$ssClass@simulator.type <- ifelse(input$coalescent,"c","f")
    for (s in 1:length(rValues$ssClass@scenarios))
        if (input$coalescent)
            {
                rValues$ssClass@scenarios[[s]]@simulator.params <-
                    new("fastsimcoal.params")
            } else {
                rValues$ssClass@scenarios[[s]]@simulator.params <-
                    new("rmetasim.params")
            }
})

observeEvent(input$reps, {
    rValues$ssClass@num.reps <- input$reps
})
observeEvent(input$wd, {
    rValues$ssClass@wd <- input$wd
                    })


###### scenario parameter updates
###### more complex, because it requires tracking which scenario
######

observeEvent(input$scenarioNumber,
             {
                 rValues$scenarioNumber <- input$scenarioNumber
             },priority=1000)


observeEvent(input$numpops,
             {
                 rValues$ssClass@scenarios[[rValues$scenarioNumber]]@num.pops <- input$numpops
             })
observeEvent(input$numloci,
             {
                 rValues$ssClass@scenarios[[rValues$scenarioNumber]]@num.loci <- input$numloci
             })

observeEvent(input$mutrate,
             {
                 rValues$ssClass@scenarios[[rValues$scenarioNumber]]@mut.rate <- input$mutrate
             })

observeEvent(input$migModel,
             {
                 rValues$ssClass@scenarios[[rValues$scenarioNumber]]@mig.helper$migModel <- input$migModel
             })

observeEvent(input$migRate,
             {
                 rValues$ssClass@scenarios[[rValues$scenarioNumber]]@mig.helper$migRate <- input$migRate
             })

observeEvent(input$rows,
             {
                 rValues$ssClass@scenarios[[rValues$scenarioNumber]]@mig.helper$rows <- input$rows
             })

observeEvent(input$cols,
             {
                 rValues$ssClass@scenarios[[rValues$scenarioNumber]]@mig.helper$cols <- input$cols
             })
observeEvent(input$distfun,
             {
                 rValues$ssClass@scenarios[[rValues$scenarioNumber]]@mig.helper$distfun <- input$distfun
             })

####simcoal parameters
observeEvent(input$specScenNumber,
             {
                 rValues$scenarioNumber <- input$specScenNumber
             })

observeEvent(input$infSiteModel,
             {
                 rValues$ssClass@scenarios[[rValues$scenarioNumber]]@simulator.params@inf.site.model <- input$infSiteModel
             })




##############################################################################################

#### this section updates the input boxes if a ssClass updates 
####
#######this observer is intended to run any time ssClass changes
####### it needs to be able to update inputs



observeEvent(rValues$ssClass,{
    if (!is.null(rValues$ssClass@title))
        updateTextInput(session,"title",value=rValues$ssClass@title)
    if (!is.null(rValues$ssClass@quiet))
        updateCheckboxInput(session,"quiet",value=rValues$ssClass@quiet)
    if (!is.null(rValues$ssClass@simulator.type))
        updateCheckboxInput(session,"coalescent",value=ifelse(rValues$ssClass@simulator.type=="c",T,F))
    if (!is.null(rValues$ssClass@num.reps))
        updateNumericInput(session,"reps",value=rValues$ssClass@num.reps)
    if (!is.null(rValues$ssClass@wd))
            updateTextInput(session,"wd",value=rValues$ssClass@wd)

##scenarios #respect the scenarioNumber!
    
    if (!is.null(rValues$ssClass@scenarios[[rValues$scenarioNumber]]@num.pops))
        updateNumericInput(session,"numpops",value=rValues$ssClass@scenarios[[rValues$scenarioNumber]]@num.pops)

    if (!is.null(rValues$ssClass@scenarios[[rValues$scenarioNumber]]@num.loci))
        updateNumericInput(session,"numloci",value=rValues$ssClass@scenarios[[rValues$scenarioNumber]]@num.loci)

    if (!is.null(rValues$ssClass@scenarios[[rValues$scenarioNumber]]@mut.rate))
        updateNumericInput(session,"mutrate",value=rValues$ssClass@scenarios[[rValues$scenarioNumber]]@mut.rate)
    
    ### needed for keeping track of how matrices are built in different scenarios
    if (!is.null(rValues$ssClass@scenarios[[rValues$scenarioNumber]]@mig.helper$migModel))
        updateSelectInput(session,"migModel",selected=rValues$ssClass@scenarios[[rValues$scenarioNumber]]@mig.helper$migModel)
    if (!is.null(rValues$ssClass@scenarios[[rValues$scenarioNumber]]@mig.helper$migRate))
        updateNumericInput(session,"migRate",value=rValues$ssClass@scenarios[[rValues$scenarioNumber]]@mig.helper$migRate)
    if (!is.null(rValues$ssClass@scenarios[[rValues$scenarioNumber]]@mig.helper$rows))
        updateNumericInput(session,"rows",value=rValues$ssClass@scenarios[[rValues$scenarioNumber]]@mig.helper$rows)
    if (!is.null(rValues$ssClass@scenarios[[rValues$scenarioNumber]]@mig.helper$cols))
        updateNumericInput(session,"cols",value=rValues$ssClass@scenarios[[rValues$scenarioNumber]]@mig.helper$cols)
    if (!is.null(rValues$ssClass@scenarios[[rValues$scenarioNumber]]@mig.helper$distfun))
        updateTextInput(session,"distfun",value=rValues$ssClass@scenarios[[rValues$scenarioNumber]]@mig.helper$distfun)

####  this is the fastsimcoal updater
    if (input$coalescent)
        if (!is.null(rValues$ssClass@scenarios[[rValues$scenarioNumber]]@simulator.params@inf.site.model))
            {
                rValues$ssClass@scenarios[[rValues$scenarioNumber]]@simulator.params@inf.site.model <- input$infSiteModel
            }
    
})

###change stuff if the scenario number changes
### this is a central 'function' that has grown organically.  In other words, its a mess.
###
observeEvent(rValues$scenarioNumber,
             {

################ migration
                 mat <- inmat()
             print(mat)
print("this far in rv$scennum")
                 if (!scenario.exists()) 
                     {
                         print("adding a new scenario")
                         rValues$ssClass@scenarios <- c(rValues$ssClass@scenarios,rValues$ssClass@scenarios[1])
                     }

#                 if (!identical(mat,rValues$ssClass@scenarios[[rValues$lstScenario]]@migration[[1]]))
#                     {
                         print("setting last scenario to mat")
                         rValues$ssClass@scenarios[[rValues$lstScenario]]@migration[[1]] <- mat
#                     }
                 
###################
                 
                 if (input$coalescent) #simcoal
                     {
                         if (!is.null(rValues$ssClass@scenarios[[rValues$lstScenario]]@simulator.params))
                             rValues$ssClass@scenarios[[rValues$lstScenario]]@simulator.params@hist.ev <- rValues$history

                         if (!is.null(rValues$ssClass@scenarios[[rValues$scenarioNumber]]@simulator.params@hist.ev))
                             {
                                # rValues$history <- rValues$ssClass@scenarios[[rValues$scenarioNumber]]@simulator.params@hist.ev
                             } else {
                                   rValues$history <- NULL
                             }
                     }


                 rValues$lstScenario <- rValues$scenarioNumber
print(rValues$scenarioNumber)
                 ######## update the scenario input boxes
                 updateNumericInput(session,"scenarioNumber",value=rValues$scenarioNumber)
                 updateNumericInput(session,"specScenNumber",value=rValues$scenarioNumber)
             },priority=100)



###this observeEvent makes sure that the migration matrix stored in the reactive class is updated continuously
###very important!!!
observeEvent(inmat(),{
    rValues$ssClass@scenarios[[rValues$scenarioNumber]]@migration[[1]] <- inmat()
})


### simcoal history updating
observeEvent(hst(),{
    rValues$ssClass@scenarios[[rValues$scenarioNumber]]@simulator.params@hist.ev <- hst()
})
