import os,
       gts

const
  sdkPath = currentSourcePath.parentDir()/"JoltPhysics"
  headerDir = sdkPath/"Jolt"

when defined(Windows): 
  
  # {.passC: "/I" & headerDir/"AABBTree".}
  # {.passC: "/I \"C:\\Program Files (x86)\\Microsoft Visual Studio\\2019\\Community\\VC\\Tools\\MSVC\\14.28.29333\\include\"".}
  {.passC: "/I" & headerDir.}

  {.link: "kernel32.lib".}
  {.link: sdkPath/"Build/VS2019_CL/Debug/Jolt.lib".}
else:
  {.error: "platform not supported!".}

include ../src/fragpkg/priv/jolt_job_system

{.emit:"""
JobSystemImpl::BarrierImpl::BarrierImpl()
{
  this->mMicroScheduler.setActiveState(false);
}

JobSystemImpl::BarrierImpl::~BarrierImpl()
{
}

JobSystemImpl::JobSystemImpl(uint inMaxBarriers)
{
  mJobs.Init(1024, 1024);

  mMaxBarriers = inMaxBarriers;
	mBarriers = new BarrierImpl [inMaxBarriers];
  
  bool result = mWorkerPool.initialize();
  GTS_ASSERT(result);
	result = mMicroScheduler.initialize(&mWorkerPool);
	GTS_ASSERT(result);
}

JobSystemImpl::~JobSystemImpl()
{
	delete [] mBarriers;
}

JobSystem::JobHandle JobSystemImpl::CreateJob(const char *inJobName, ColorArg inColor, const JobSystem::JobFunction &inJobFunction, uint32 inNumDependencies)
{
	uint32 index;
	for (;;)
	{
		index = mJobs.ConstructObject(inJobName, inColor, this, inJobFunction, inNumDependencies);
		if (index != AvailableJobs::cInvalidObjectIndex)
			break;
		JPH_ASSERT(false, "No jobs available!");
		this_thread::sleep_for(100us);
	}
	JobSystem::Job *job = &mJobs.Get(index);
	
	JobSystem::JobHandle handle(job);
	
	if (inNumDependencies == 0)
		QueueJob(job);

	return handle;
}

JobSystem::Barrier *JobSystemImpl::CreateBarrier(void)
{
  for (uint32 index = 0; index < mMaxBarriers; ++index)
	{
		BarrierImpl *b = &mBarriers[index];
		if (!b->mMicroScheduler.isActive()) {
      b->mMicroScheduler.setActiveState(true);
			b->mMicroScheduler.initialize(&this->mWorkerPool);
			return b;
		}
	}

	return nullptr;
}

void JobSystemImpl::DestroyBarrier(JobSystem::Barrier *inBarrier)
{
  JPH_ASSERT(!static_cast<BarrierImpl *>(inBarrier)->mMicroScheduler.hasTasks());
  static_cast<BarrierImpl *>(inBarrier)->mMicroScheduler.setActiveState(false);
}

void JobSystemImpl::WaitForJobs(JobSystem::Barrier *inBarrier)
{
	static_cast<BarrierImpl *>(inBarrier)->mMicroScheduler.waitForAll();
}

void JobSystemImpl::QueueJob(JobSystem::Job *inJob)
{
	inJob->AddRef();

	gts::Task* pTask = mMicroScheduler.allocateTask<JobTask>(inJob);
}

void JobSystemImpl::QueueJobs(JobSystem::Job **inJobs, uint inNumJobs)
{
}

void JobSystemImpl::FreeJob(JobSystem::Job *inJob)
{
	mJobs.DestructObject(inJob);
}

void JobSystemImpl::BarrierImpl::AddJob(const JobSystem::JobHandle &inJob)
{
	Job *job = inJob.GetPtr();
	if (job->SetBarrier(this))
	{
		job->AddRef();
		gts::Task* pTask = mMicroScheduler.allocateTask<JobTask>(job);
		mMicroScheduler.spawnTask(pTask);
	}
}

void JobSystemImpl::BarrierImpl::AddJobs(const JobSystem::JobHandle *inHandles, uint inNumHandles)
{
}

void JobSystemImpl::BarrierImpl::OnJobFinished(JobSystem::Job *inJob)
{
}
"""
.}

type
  JobFunction* {.importcpp: "JobSystem::JobFunction".} = proc() {.cdecl, gcsafe.}
  JobHandle* {.importcpp: "JPH::JobSystem::JobHandle".} = object
  Color* {.importcpp: "JPH::Color".} = object
  Barrier* {.importcpp: "JPH::JobSystem::Barrier", inheritable.} = object
  IJobSystem* {.importcpp: "JobSystem", inheritable.} = object
  JobSystem* {.importcpp: "JobSystemImpl".} = object of IJobSystem

proc newColor*(r, g, b: uint8): Color  {.importcpp: "Color(@)".}

let
  sGreen = newColor(0, 255, 0)

proc newJobSystem*(maxBarriers: uint): ptr JobSystem {.importcpp: "new JobSystemImpl((JPH::uint)@)".}
proc destroy*(js: ptr JobSystem) {.importcpp: "delete #".}
proc createJob*(js: ptr JobSystem; name: cstring; inColor: Color; inJobFunction: JobFunction; inNumDependencies = 0'u32): JobHandle {.importcpp: "#->CreateJob(#, #, #, @)".}
proc createBarrier*(js: ptr JobSystem): ptr Barrier {.importcpp: "#->CreateBarrier()".}
proc destroyBarrier*(js: ptr JobSystem; b: ptr Barrier) {.importcpp: "#->DestroyBarrier(reinterpret_cast<JPH::JobSystem::Barrier*>(@))".}
proc addJob*(b: ptr Barrier; jh: JobHandle) {.importcpp: "reinterpret_cast<JPH::JobSystem::Barrier*>(#)->AddJob(@)".}
proc waitForJobs*(js: ptr JobSystem; b: ptr Barrier) {.importcpp: "#->WaitForJobs(@)".}

when isMainModule:
  const maxPhysicsBarriers = 8'u

  let 
    js = newJobSystem(maxPhysicsBarriers)
    firstJob = js.createJob("TestJob", sGreen, proc() {.cdecl, gcsafe.} = echo "foo")
    barrier = js.createBarrier()
  
  barrier.addJob(firstJob)
  js.waitForJobs(barrier)