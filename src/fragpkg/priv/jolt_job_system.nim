{.emit: """/*INCLUDESECTION*/
#include <Core/Core.h>
#include <Core/IssueReporting.h>
#include <Math/Math.h>
#include <Math/Vec4.h>
#include <Core/Color.h>
#include <Core/FixedSizeFreeList.h>
#include <Core/JobSystem.h>
#include <gts/platform/Assert.h>
#include <gts/platform/Thread.h>
#include <gts/micro_scheduler/WorkerPool.h>
#include <gts/micro_scheduler/MicroScheduler.h>

#include <thread>
#include <mutex>
#include <condition_variable>

#ifdef JPH_PLATFORM_WINDOWS
	#pragma warning (push, 0)
	#pragma warning (disable : 5039) // winbase.h(13179): warning C5039: 'TpSetCallbackCleanupGroup': pointer or reference to potentially throwing function passed to 'extern "C"' function under -EHc. Undefined behavior may occur if this function throws an exception.
	#define WIN32_LEAN_AND_MEAN
	#include <windows.h>
	#pragma warning (pop)
#endif

/*TYPESECTION*/
using namespace std;
using namespace std::chrono_literals;
using namespace JPH;

class JobSystemImpl final: public JobSystem
{
public:
  JobSystemImpl(uint inMaxBarriers);
  virtual ~JobSystemImpl() override;
  
  virtual int GetMaxConcurrency() const override { return gts::Thread::getHardwareThreadCount(); }
  virtual JobSystem::JobHandle		CreateJob(const char *inName, ColorArg inColor, const JobSystem::JobFunction &inJobFunction, uint32 inNumDependencies = 0) override;
  virtual JobSystem::Barrier *JobSystem::CreateBarrier(void) override;
  virtual void			DestroyBarrier(JobSystem::Barrier *inBarrier) override;
  virtual void			WaitForJobs(JobSystem::Barrier *inBarrier) override;

  virtual void			QueueJob(JobSystem::Job *inJob) override;
	virtual void			QueueJobs(JobSystem::Job **inJobs, uint inNumJobs) override;
	virtual void			FreeJob(JobSystem::Job *inJob) override;

private:
	struct JobTask : public gts::Task
	{
		JobTask(Job *j) : job(j) {}

		virtual Task * execute(gts::TaskContext const&) final
		{
			if (job->CanBeExecuted())
			{
				job->Execute();
				job->Release();
			}
			else
			{
				recycle();
			}
			return nullptr;
		}

		Job *job;
	};

  class BarrierImpl : public JobSystem::Barrier
  {
  public:
    BarrierImpl();
    virtual ~BarrierImpl() override;

    virtual void AddJob(const JobSystem::JobHandle &inJob) override;
    virtual void	AddJobs(const JobSystem::JobHandle *inHandles, uint inNumHandles) override;
  protected:
    virtual void	OnJobFinished(Job *inJob) override;
	private:
    gts::MicroScheduler mMicroScheduler;

		friend class JobSystemImpl;
  };

  using AvailableJobs = FixedSizeFreeList<Job>;
	AvailableJobs			mJobs;

	uint mMaxBarriers;
  BarrierImpl *mBarriers;

	gts::WorkerPool mWorkerPool;
	gts::MicroScheduler mMicroScheduler;
};
""".}