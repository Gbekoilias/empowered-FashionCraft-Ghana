import React, { useState, useEffect, useCallback } from 'react';
import { ArrowRight, Clock, Users, Activity } from 'lucide-react';

const WorkflowOptimizer = () => {
  const [workflow, setWorkflow] = useState({
    steps: [],
    metrics: {
      timePerStep: 0,
      participantCount: 0,
      efficiency: 0
    }
  });

  const [userInput, setUserInput] = useState({
    newStep: '',
    timeAllocation: 0,
    participants: []
  });

  const calculateEfficiency = useCallback((steps, participants) => {
    if (steps.length === 0) return 0;
    const avgTimePerStep = steps.reduce((acc, step) => acc + step.time, 0) / steps.length;
    const participantFactor = participants.length > 0 ? participants.length / 10 : 1;
    return ((100 / avgTimePerStep) * participantFactor).toFixed(2);
  }, []);

  const addWorkflowStep = () => {
    if (!userInput.newStep) return;
    
    setWorkflow(prev => {
      const newSteps = [...prev.steps, {
        id: Date.now(),
        name: userInput.newStep,
        time: userInput.timeAllocation
      }];
      
      return {
        steps: newSteps,
        metrics: {
          timePerStep: newSteps.reduce((acc, step) => acc + step.time, 0) / newSteps.length,
          participantCount: userInput.participants.length,
          efficiency: calculateEfficiency(newSteps, userInput.participants)
        }
      };
    });

    setUserInput(prev => ({...prev, newStep: '', timeAllocation: 0}));
  };

  const removeStep = (stepId) => {
    setWorkflow(prev => {
      const newSteps = prev.steps.filter(step => step.id !== stepId);
      return {
        steps: newSteps,
        metrics: {
          timePerStep: newSteps.length ? newSteps.reduce((acc, step) => acc + step.time, 0) / newSteps.length : 0,
          participantCount: userInput.participants.length,
          efficiency: calculateEfficiency(newSteps, userInput.participants)
        }
      };
    });
  };

  return (
    <div className="p-6 max-w-4xl mx-auto">
      <div className="bg-white rounded-lg shadow-md p-6">
        <h2 className="text-2xl font-bold mb-6">Workflow Optimizer</h2>
        
        <div className="grid grid-cols-3 gap-4 mb-6">
          <div className="p-4 bg-blue-50 rounded-lg flex items-center">
            <Clock className="mr-2" />
            <div>
              <p className="text-sm text-gray-600">Average Time</p>
              <p className="text-xl font-bold">{workflow.metrics.timePerStep}m</p>
            </div>
          </div>
          
          <div className="p-4 bg-green-50 rounded-lg flex items-center">
            <Users className="mr-2" />
            <div>
              <p className="text-sm text-gray-600">Participants</p>
              <p className="text-xl font-bold">{workflow.metrics.participantCount}</p>
            </div>
          </div>
          
          <div className="p-4 bg-purple-50 rounded-lg flex items-center">
            <Activity className="mr-2" />
            <div>
              <p className="text-sm text-gray-600">Efficiency</p>
              <p className="text-xl font-bold">{workflow.metrics.efficiency}%</p>
            </div>
          </div>
        </div>

        <div className="mb-6">
          <div className="flex gap-4 mb-4">
            <input
              type="text"
              value={userInput.newStep}
              onChange={(e) => setUserInput(prev => ({...prev, newStep: e.target.value}))}
              placeholder="Add new step"
              className="flex-1 p-2 border rounded"
            />
            <input
              type="number"
              value={userInput.timeAllocation}
              onChange={(e) => setUserInput(prev => ({...prev, timeAllocation: parseInt(e.target.value)}))}
              placeholder="Time (minutes)"
              className="w-32 p-2 border rounded"
            />
            <button
              onClick={addWorkflowStep}
              className="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600"
            >
              Add Step
            </button>
          </div>
        </div>

        <div className="space-y-4">
          {workflow.steps.map((step, index) => (
            <div key={step.id} className="flex items-center p-4 bg-gray-50 rounded-lg">
              <span className="w-8 h-8 flex items-center justify-center bg-blue-100 rounded-full mr-4">
                {index + 1}
              </span>
              <span className="flex-1">{step.name}</span>
              <span className="mx-4 text-gray-600">{step.time}m</span>
              <button
                onClick={() => removeStep(step.id)}
                className="px-3 py-1 text-red-500 hover:bg-red-50 rounded"
              >
                Remove
              </button>
              {index < workflow.steps.length - 1 && (
                <ArrowRight className="mx-2 text-gray-400" />
              )}
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};

export default WorkflowOptimizer;