import { useEffect, useState } from 'react';
import Head from 'next/head';
import styles from '../styles/Home.module.sass';
import intraLaunch from '../intraLaunch.json';

export default function Home() {
  const launchScript = (task, program, workingfolder) => {
    document.dispatchEvent(
      new CustomEvent('funcIntraLaunch', {
        detail: {
          task,
          program,
          workingfolder,
        },
      })
    );
  };

  return (
    <>
      <Head>
        <title>{intraLaunch.initial.title} - eQuick</title>
        <meta name='description' content='eQuick launcher' />
        <link rel='icon' href='/favicon.ico' />
      </Head>

      <h1 className={styles.title}>{intraLaunch.initial.title}</h1>
      <div className={styles['create-container']}>
        <a href='#' className={styles['create-link']} onClick={() => launchScript('run', `${intraLaunch.initial.projectLocation}/data/scripts/nextjs.ps1`, intraLaunch.initial.projectLocation)}>
          <img className={styles['project-icon']} src='nextjs.svg' alt='Next ' />
        </a>
      </div>
      <div className={styles['project-flex']}>
        {intraLaunch.nextjs.map((elem, i) => (
          <div key={i} className={styles['project-container']}>
            <div className={styles['project-link']}>
              <img className={styles['project-icon']} src='nextjs.svg' alt='Next ' />
              {elem.name}
            </div>
            {elem.commit && (
              <div className={styles['git-container']}>
                <a href='#' className={styles['git-link']} onClick={() => launchScript('run', elem.commit, intraLaunch.initial.projectLocation)}>
                  <img className={styles['git-icon']} src='gitcommit.png' alt='Git Commit ' />
                </a>
                <a href='#' className={styles['git-link']} onClick={() => launchScript('run', elem.push, intraLaunch.initial.projectLocation)}>
                  <img className={styles['git-icon']} src='push.webp' alt='Git Push' />
                </a>
                <a href='#' className={styles['git-link']} onClick={() => launchScript('run', elem.delete, intraLaunch.initial.projectLocation)}>
                  <img className={styles['git-icon']} src='push.webp' alt='Git Push' />
                </a>
              </div>
            )}
          </div>
        ))}
      </div>
      <div className={styles['logo-container']}>
        <img className={styles['equick-logo']} src='equicklogo.png' alt='' />
        <p>eQuick</p>
      </div>
    </>
  );
}
